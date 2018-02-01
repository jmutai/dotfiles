#!/usr/bin/perl -w
# Copyright (C) 2015 Richard W.M. Jones <rjones@redhat.com>
# Copyright (C) 2015 Red Hat Inc.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use warnings;
use strict;
use English;

use Pod::Usage;
use Getopt::Long;
use File::Temp qw(tempdir);
use POSIX qw(_exit setgid setuid strftime);
use XML::Writer;

use Sys::Guestfs;

=head1 NAME

import-to-ovirt.pl - Import virtual machine disk image to RHEV or oVirt

=head1 SYNOPSIS

 sudo ./import-to-ovirt.pl disk.img server:/esd

 sudo ./import-to-ovirt.pl disk.img /esd_mountpoint

=head1 IMPORTANT NOTES

In the latest oVirt/RHEV/RHV there is a GUI option to import disks.
You B<do not need to use this script> if you are using a sufficiently
new version of oVirt.

This tool should B<only> be used if the guest can already run on KVM.

B<If you need to convert the guest from some foreign hypervisor, like VMware, Xen or Hyper-V, you should use L<virt-v2v(1)> instead.>

=head1 EXAMPLES

Import a KVM guest to the Export Storage Domain of your RHEV or oVirt
system.  The NFS mount of the Export Storage Domain is C<server:/esd>.

 sudo ./import-to-ovirt.pl disk.img server:/esd

Import a KVM guest to an already-mounted Export Storage Domain:

 sudo ./import-to-ovirt.pl disk.img /esd_mountpoint

If the single guest has multiple disks, use:

 sudo ./import-to-ovirt.pl disk1.img [disk2.img [...]] server:/esd

If you are importing multiple guests then you must import each one
separately.  Do not use multiple disk parameters if each disk comes
from a different guest.

=head1 DESCRIPTION

This is a command line script for importing a KVM virtual machine to
RHEV or oVirt.  The script assumes that the guest can already run on
KVM, ie. that it was previously running on KVM and has the required
drivers.  If the guest comes from a foreign hypervisor like VMware,
Xen or Hyper-V, use L<virt-v2v(1)> instead.

This script only imports the guest into the oVirt "Export Storage
Domain" (ESD).  After the import is complete, you must then go to the
oVirt user interface, go to the C<Storage> tab, select the right ESD,
and use C<VM Import> to take the guest from the ESD to the data
domain.  This process is outside the scope of this script, but could
be automated using the oVirt API.

=head2 Basic usage

Basic usage is just:

 ./import-to-ovirt.pl [list of disks] server:/esd

If you are unclear about the C<server:/esd> parameter, go to the oVirt
Storage tab, select the C<Domain Type> C<Export> and look in the
C<General> tab under C<Path>.

If the ESD is already mounted on your machine (or if you are using a
non-NFS ESD), then you can supply a direct path to the mountpoint
instead:

 ./import-to-ovirt.pl [list of disks] /esd_mountpoint

The list of disks should all belong to a single guest (most guests
will only have a single disk).  If you want to import multiple guests,
you must run the script multiple times.

Importing from OVA etc is not supported.  Try C<ovirt-image-uploader>
(if the OVA was exported from oVirt), or L<virt-v2v(1)> (if the OVA
was exported from VMware).

=head2 Permissions

You probably need to run this script as root, because it has to create
files on the ESD as a special C<vdsm> user (UID:GID C<36:36>).

It may also be possible to run the script as the vdsm user.  But if
you run it as some non-root, non-vdsm user, then oVirt won't be able
to read the data from the ESD and will give an error.

NFS "root squash" should be turned off on the NFS server, since it
stops us from creating files as the vdsm user.  Also NFSv4 may not
work unless you have set up idmap correctly (good luck!)

=head2 Network card and disk model

(See also L</TO DO> below)

Currently this script doesn't add a network card to the guest.  You
will need to add one yourself in the C<VM Import> tab when importing
the guest.

Similarly, the script always adds the disks as virtio-blk devices.  If
the guest is expecting IDE, SCSI or virtio-scsi, you will need to
change the disk type when importing the guest.

=head1 OPTIONS

=over 4

=cut

my $help;

=item B<--help>

Display brief help and exit.

=cut

my $man;

=item B<--man>

Display the manual page and exit.

=cut

my $memory_mb = 1024;

=item B<--memory> MB

Set the memory size I<in megabytes>.  The default is 1024.

=cut

my $name;

=item B<--name> name

Set the guest name.  If not present, a name is made up based on
the filename of the first disk.

=cut

my $vcpus = 1;

=item B<--vcpus> N

Set the number of virtual CPUs.  The default is 1.

=cut

my $vmtype = "Desktop";

=item B<--vmtype> Desktop

=item B<--vmtype> Server

Set the VmType field in the OVF.  It must be C<Desktop> or
C<Server>.  The default is C<Desktop>.

=cut

=back

=cut

$| = 1;

GetOptions ("help|?" => \$help,
            "man" => \$man,
            "memory=i" => \$memory_mb,
            "name=s" => \$name,
            "vcpus=i" => \$vcpus,
            "vmtype=s" => \$vmtype,
    )
    or die "$0: unknown command line option\n";

pod2usage (1) if $help;
pod2usage (-exitval => 0, -verbose => 2) if $man;

# Get the parameters.
if (@ARGV < 2) {
    die "Use '$0 --man' to display the manual.\n"
}

my @disks = @ARGV[0 .. $#ARGV-1];
my $output = $ARGV[$#ARGV];

if (!defined $name) {
    $name = $disks[0];
    $name =~ s{.*/}{};
    $name =~ s{\.[^.]+}{};
}

if ($vmtype =~ /^Desktop$/i) {
    $vmtype = 0;
} elsif ($vmtype =~ /^Server$/i) {
    $vmtype = 1;
} else {
    die "$0: --vmtype parameter must be 'Desktop' or 'Server'\n"
}

# Does qemu-img generally work OK?
system ("qemu-img create -f qcow2 .test.qcow2 10M >/dev/null") == 0
    or die "qemu-img command not installed or not working\n";

# Does this version of qemu-img support compat=0.10?  RHEL 6
# did NOT support it.
my $qemu_img_supports_compat = 0;
system ("qemu-img create -f qcow2 -o compat=0.10 .test.qcow2 10M >/dev/null 2>&1") == 0
    and $qemu_img_supports_compat = 1;
unlink ".test.qcow2";

# Open the guest in libguestfs so we can inspect it.
my $g = Sys::Guestfs->new ();
eval { $g->set_program ("virt-import-to-ovirt"); };
$g->add_drive_opts ($_, readonly => 1) foreach (@disks);
$g->launch ();
my @roots = $g->inspect_os ();
if (@roots == 0) {
    die "$0: no operating system was found on the disk\n"
}
if (@roots > 1) {
    die "$0: either this is a multi-OS disk, or you passed multiple unrelated guest disks on the command line\n"
}
my $root = $roots[0];

# Save the inspection data.
my $type = $g->inspect_get_type ($root);
my $distro = $g->inspect_get_distro ($root);
my $arch = $g->inspect_get_arch ($root);
my $major_version = $g->inspect_get_major_version ($root);
my $minor_version = $g->inspect_get_minor_version ($root);
my $product_name = $g->inspect_get_product_name ($root);
my $product_variant = $g->inspect_get_product_variant ($root);

# Get the virtual size of each disk.
my @virtual_sizes;
foreach (@disks) {
    push @virtual_sizes, $g->disk_virtual_size ($_);
}

$g->close ();

# Map inspection data to RHEV ostype.
my $ostype;
if ($type eq "linux" && $distro eq "rhel" && $major_version <= 6) {
    if ($arch eq "x86_64") {
        $ostype = "RHEL${major_version}x64"
    } else {
        $ostype = "RHEL$major_version"
    }
}
elsif ($type eq "linux" && $distro eq "rhel") {
    if ($arch eq "x86_64") {
        $ostype = "rhel_${major_version}x64"
    } else {
        $ostype = "rhel_$major_version"
    }
}
elsif ($type eq "linux") {
    $ostype = "OtherLinux"
}
elsif ($type eq "windows" && $major_version == 5 && $minor_version == 1) {
    $ostype = "WindowsXP"
}
elsif ($type eq "windows" && $major_version == 5 && $minor_version == 2) {
    if ($product_name =~ /XP/) {
        $ostype = "WindowsXP"
    } elsif ($arch eq "x86_64") {
        $ostype = "Windows2003x64"
    } else {
        $ostype = "Windows2003"
    }
}
elsif ($type eq "windows" && $major_version == 6 && $minor_version == 0) {
    if ($arch eq "x86_64") {
        $ostype = "Windows2008x64"
    } else {
        $ostype = "Windows2008"
    }
}
elsif ($type eq "windows" && $major_version == 6 && $minor_version == 1) {
    if ($product_variant eq "Client") {
        if ($arch eq "x86_64") {
            $ostype = "Windows7x64"
        } else {
            $ostype = "Windows7"
        }
    } else {
        $ostype = "Windows2008R2x64"
    }
}
elsif ($type eq "windows" && $major_version == 6 && $minor_version == 2) {
   if ($product_variant eq "Client") {
       if ($arch eq "x86_64") {
           $ostype = "windows_8x64"
       } else {
           $ostype = "windows_8"
       }
   } else {
       $ostype = "windows_2012x64"
   }
}
elsif ($type eq "windows" && $major_version == 6 && $minor_version == 3) {
    $ostype = "windows_2012R2x64"
}
else {
    $ostype = "Unassigned"
}

# Mount the ESD if needed (or just check it exists).
my $mountpoint;
if (-d $output) {
    $mountpoint = $output;
} elsif ($output =~ m{^.*:.*$}) {
    my $umount;
    $umount = $mountpoint = tempdir (CLEANUP => 1);
    system ("mount", "-t", "nfs", $output, $mountpoint) == 0
        or die "$0: mount $output failed: $?\n";
    END { system ("umount", $umount) if defined $umount }
} else {
    die "$0: ESD $output is not a directory or an NFS mountpoint\n"
}

# Check the ESD looks like an ESD.
my @entries = <$mountpoint/*>;
@entries =
    grep { m{/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$}i }
    @entries;
if (@entries == 0) {
    die "$0: does $output really point to an oVirt Export Storage Domain?\n"
}
if (@entries > 1) {
    die "$0: multiple GUIDs found in oVirt Export Storage Domain\n"
}
my $esd_uuid_dir = $entries[0];
my $esd_uuid = $esd_uuid_dir;
$esd_uuid =~ s{.*/}{};

if (! -d $esd_uuid_dir ||
    ! -d "$esd_uuid_dir/images" ||
    ! -d "$esd_uuid_dir/master" ||
    ! -d "$esd_uuid_dir/master/vms") {
    die "$0: $output doesn't look like an Export Storage Domain\n"
}

# Start the import.
print "Importing $product_name to $output...\n";

# A helper function that forks and runs some code / a command as
# an alternate UID:GID.
sub run_as_vdsm
{
    my $fn = shift;

    my $pid = fork ();
    die "fork: $!" unless defined $pid;
    if ($pid == 0) {
        # Child process.
        if ($EUID == 0) {
            setgid (36);
            setuid (36);
        }
        eval { &$fn () };
        if ($@) {
            print STDERR "$@\n";
            _exit (1);
        }
        _exit (0);
    }
    waitpid ($pid, 0) or die "waitpid: $!";
    if ($? != 0) {
        die "$0: run_as_vdsm: child process failed (status $?)\n";
    }
}

# Generate a UUID.
sub uuidgen
{
    local $_ = `uuidgen -r`;
    chomp;
    die unless length $_ >= 30; # Sanity check.
    $_;
}

# Generate some random UUIDs.
my $vm_uuid = uuidgen ();
my @image_uuids;
foreach (@disks) {
    push @image_uuids, uuidgen ();
}
my @vol_uuids;
foreach (@disks) {
    push @vol_uuids, uuidgen ();
}

# Make sure the output is deleted on unsuccessful exit.  We set
# $delete_output_on_exit to false at the end of the script.
my $delete_output_on_exit = 1;
END {
    if ($delete_output_on_exit) {
        # Can't use run_as_vdsm in an END{} block.
        foreach (@image_uuids) {
            system ("rm", "-rf", "$esd_uuid_dir/images/$_");
        }
        system ("rm", "-rf", "$esd_uuid_dir/master/vms/$vm_uuid");
    }
};

# Copy and convert the disk images.
my $i;
my $time = time ();
my $iso_time = strftime ("%Y/%m/%d %H:%M:%S", gmtime ());
my $imported_by = "Imported by import-to-ovirt.pl";
my @real_sizes;

for ($i = 0; $i < @disks; ++$i) {
    my $input_file = $disks[$i];
    my $image_uuid = $image_uuids[$i];
    run_as_vdsm (sub {
        my $path = "$esd_uuid_dir/images/$image_uuid";
        mkdir ($path, 0755) or die "mkdir: $path: $!";
    });
    my $output_file = "$esd_uuid_dir/images/$image_uuid/".$vol_uuids[$i];
    run_as_vdsm (sub {
        open (my $fh, ">", $output_file) or die "open: $output_file: $!";
        # Well done NFS root_squash, you make the world less secure.
        chmod (0666, $output_file) or die "chmod: $output_file: $!";
    });
    print "Copying $input_file ...\n";
    my @compat_option = ();
    if ($qemu_img_supports_compat) {
        @compat_option = ("-o", "compat=0.10") # for RHEL 6-based ovirt nodes
    }
    system ("qemu-img", "convert", "-p",
            $input_file,
            "-O", "qcow2",
            @compat_option,
            $output_file) == 0
                or die "qemu-img: $input_file: failed (status $?)";
    push @real_sizes, -s $output_file;

    my $size_in_sectors = $virtual_sizes[$i] / 512;

    # Create .meta files per disk.
    my $meta = <<"EOF";
DOMAIN=$esd_uuid
VOLTYPE=LEAF
CTIME=$time
MTIME=$time
IMAGE=$image_uuid
DISKTYPE=1
PUUID=00000000-0000-0000-0000-000000000000
LEGALITY=LEGAL
POOL_UUID=
SIZE=$size_in_sectors
FORMAT=COW
TYPE=SPARSE
DESCRIPTION=$imported_by
EOF
    my $meta_file = $output_file . ".meta";
    run_as_vdsm (sub {
        open (my $fh, ">", $meta_file) or die "open: $meta_file: $!";
        print $fh $meta
    });
}

# Create the OVF.
print "Creating OVF metadata ...\n";

my $rasd_ns = "http://schemas.dmtf.org/wbem/wscim/1/cim-schema/2/CIM_ResourceAllocationSettingData";
my $vssd_ns = "http://schemas.dmtf.org/wbem/wscim/1/cim-schema/2/CIM_VirtualSystemSettingData";
my $xsi_ns = "http://www.w3.org/2001/XMLSchema-instance";
my $ovf_ns = "http://schemas.dmtf.org/ovf/envelope/1/";
my %prefix_map = (
    $rasd_ns => "rasd",
    $vssd_ns => "vssd",
    $xsi_ns => "xsi",
    $ovf_ns => "ovf",
);
my @forced_ns_decls = keys %prefix_map;

my $ovf = "";
my $w = XML::Writer->new (
    OUTPUT => \$ovf,
    NAMESPACES => 1,
    PREFIX_MAP => \%prefix_map,
    FORCED_NS_DECLS => \@forced_ns_decls,
    DATA_MODE => 1,
    DATA_INDENT => 4,
);

$w->startTag ([$ovf_ns, "Envelope"],
              [$ovf_ns, "version"] => "0.9");
$w->comment ($imported_by);

$w->startTag ("References");

for ($i = 0; $i < @disks; ++$i)
{
    my $href = $image_uuids[$i] . "/" . $vol_uuids[$i];
    $w->startTag ("File",
                  [$ovf_ns, "href"] => $href,
                  [$ovf_ns, "id"] => $vol_uuids[$i],
                  [$ovf_ns, "size"] => $virtual_sizes[$i],
                  [$ovf_ns, "description"] => $imported_by);
    $w->endTag ();
}

$w->endTag ();

$w->startTag ("Section",
              [$xsi_ns, "type"] => "ovf:NetworkSection_Type");
$w->startTag ("Info");
$w->characters ("List of networks");
$w->endTag ();
$w->endTag ();

$w->startTag ("Section",
              [$xsi_ns, "type"] => "ovf:DiskSection_Type");
$w->startTag ("Info");
$w->characters ("List of Virtual Disks");
$w->endTag ();

for ($i = 0; $i < @disks; ++$i)
{
    my $virtual_size_in_gb = $virtual_sizes[$i];
    $virtual_size_in_gb /= 1024;
    $virtual_size_in_gb /= 1024;
    $virtual_size_in_gb /= 1024;
    my $real_size_in_gb = $real_sizes[$i];
    $real_size_in_gb /= 1024;
    $real_size_in_gb /= 1024;
    $real_size_in_gb /= 1024;
    my $href = $image_uuids[$i] . "/" . $vol_uuids[$i];

    my $boot_drive;
    if ($i == 0) {
        $boot_drive = "True";
    } else {
        $boot_drive = "False";
    }

    $w->startTag ("Disk",
                  [$ovf_ns, "diskId" ] => $vol_uuids[$i],
                  [$ovf_ns, "actual_size"] =>
                      sprintf ("%.0f", $real_size_in_gb),
                  [$ovf_ns, "size"] =>
                      sprintf ("%.0f", $virtual_size_in_gb),
                  [$ovf_ns, "fileRef"] => $href,
                  [$ovf_ns, "parentRef"] => "",
                  [$ovf_ns, "vm_snapshot_id"] => uuidgen (),
                  [$ovf_ns, "volume-format"] => "COW",
                  [$ovf_ns, "volume-type"] => "Sparse",
                  [$ovf_ns, "format"] => "http://en.wikipedia.org/wiki/Byte",
                  [$ovf_ns, "disk-interface"] => "VirtIO",
                  [$ovf_ns, "disk-type"] => "System",
                  [$ovf_ns, "boot"] => $boot_drive);
    $w->endTag ();
}

$w->endTag ();

$w->startTag ("Content",
              [$ovf_ns, "id"] => "out",
              [$xsi_ns, "type"] => "ovf:VirtualSystem_Type");
$w->startTag ("Name");
$w->characters ($name);
$w->endTag ();
$w->startTag ("TemplateId");
$w->characters ("00000000-0000-0000-0000-000000000000");
$w->endTag ();
$w->startTag ("TemplateName");
$w->characters ("Blank");
$w->endTag ();
$w->startTag ("Description");
$w->characters ($imported_by);
$w->endTag ();
$w->startTag ("Domain");
$w->endTag ();
$w->startTag ("CreationDate");
$w->characters ($iso_time);
$w->endTag ();
$w->startTag ("IsInitilized"); # sic
$w->characters ("True");
$w->endTag ();
$w->startTag ("IsAutoSuspend");
$w->characters ("False");
$w->endTag ();
$w->startTag ("TimeZone");
$w->endTag ();
$w->startTag ("IsStateless");
$w->characters ("False");
$w->endTag ();
$w->startTag ("Origin");
$w->characters ("0");
$w->endTag ();
$w->startTag ("VmType");
$w->characters ($vmtype);
$w->endTag ();
$w->startTag ("DefaultDisplayType");
$w->characters ("1"); # qxl
$w->endTag ();

$w->startTag ("Section",
              [$ovf_ns, "id"] => $vm_uuid,
              [$ovf_ns, "required"] => "false",
              [$xsi_ns, "type"] => "ovf:OperatingSystemSection_Type");
$w->startTag ("Info");
$w->characters ($product_name);
$w->endTag ();
$w->startTag ("Description");
$w->characters ($ostype);
$w->endTag ();
$w->endTag ();

$w->startTag ("Section",
              [$xsi_ns, "type"] => "ovf:VirtualHardwareSection_Type");
$w->startTag ("Info");
$w->characters (sprintf ("%d CPU, %d Memory", $vcpus, $memory_mb));
$w->endTag ();

$w->startTag ("Item");
$w->startTag ([$rasd_ns, "Caption"]);
$w->characters (sprintf ("%d virtual cpu", $vcpus));
$w->endTag ();
$w->startTag ([$rasd_ns, "Description"]);
$w->characters ("Number of virtual CPU");
$w->endTag ();
$w->startTag ([$rasd_ns, "InstanceId"]);
$w->characters ("1");
$w->endTag ();
$w->startTag ([$rasd_ns, "ResourceType"]);
$w->characters ("3");
$w->endTag ();
$w->startTag ([$rasd_ns, "num_of_sockets"]);
$w->characters ($vcpus);
$w->endTag ();
$w->startTag ([$rasd_ns, "cpu_per_socket"]);
$w->characters (1);
$w->endTag ();
$w->endTag ("Item");

$w->startTag ("Item");
$w->startTag ([$rasd_ns, "Caption"]);
$w->characters (sprintf ("%d MB of memory", $memory_mb));
$w->endTag ();
$w->startTag ([$rasd_ns, "Description"]);
$w->characters ("Memory Size");
$w->endTag ();
$w->startTag ([$rasd_ns, "InstanceId"]);
$w->characters ("2");
$w->endTag ();
$w->startTag ([$rasd_ns, "ResourceType"]);
$w->characters ("4");
$w->endTag ();
$w->startTag ([$rasd_ns, "AllocationUnits"]);
$w->characters ("MegaBytes");
$w->endTag ();
$w->startTag ([$rasd_ns, "VirtualQuantity"]);
$w->characters ($memory_mb);
$w->endTag ();
$w->endTag ("Item");

$w->startTag ("Item");
$w->startTag ([$rasd_ns, "Caption"]);
$w->characters ("USB Controller");
$w->endTag ();
$w->startTag ([$rasd_ns, "InstanceId"]);
$w->characters ("3");
$w->endTag ();
$w->startTag ([$rasd_ns, "ResourceType"]);
$w->characters ("23");
$w->endTag ();
$w->startTag ([$rasd_ns, "UsbPolicy"]);
$w->characters ("Disabled");
$w->endTag ();
$w->endTag ("Item");

$w->startTag ("Item");
$w->startTag ([$rasd_ns, "Caption"]);
$w->characters ("Graphical Controller");
$w->endTag ();
$w->startTag ([$rasd_ns, "InstanceId"]);
$w->characters (uuidgen ());
$w->endTag ();
$w->startTag ([$rasd_ns, "ResourceType"]);
$w->characters ("20");
$w->endTag ();
$w->startTag ("Type");
$w->characters ("video");
$w->endTag ();
$w->startTag ([$rasd_ns, "VirtualQuantity"]);
$w->characters ("1");
$w->endTag ();
$w->startTag ([$rasd_ns, "Device"]);
$w->characters ("qxl");
$w->endTag ();
$w->endTag ("Item");

for ($i = 0; $i < @disks; ++$i)
{
    my $href = $image_uuids[$i] . "/" . $vol_uuids[$i];

    $w->startTag ("Item");

    $w->startTag ([$rasd_ns, "Caption"]);
    $w->characters ("Drive " . ($i+1));
    $w->endTag ();
    $w->startTag ([$rasd_ns, "InstanceId"]);
    $w->characters ($vol_uuids[$i]);
    $w->endTag ();
    $w->startTag ([$rasd_ns, "ResourceType"]);
    $w->characters ("17");
    $w->endTag ();
    $w->startTag ("Type");
    $w->characters ("disk");
    $w->endTag ();
    $w->startTag ([$rasd_ns, "HostResource"]);
    $w->characters ($href);
    $w->endTag ();
    $w->startTag ([$rasd_ns, "Parent"]);
    $w->characters ("00000000-0000-0000-0000-000000000000");
    $w->endTag ();
    $w->startTag ([$rasd_ns, "Template"]);
    $w->characters ("00000000-0000-0000-0000-000000000000");
    $w->endTag ();
    $w->startTag ([$rasd_ns, "ApplicationList"]);
    $w->endTag ();
    $w->startTag ([$rasd_ns, "StorageId"]);
    $w->characters ($esd_uuid);
    $w->endTag ();
    $w->startTag ([$rasd_ns, "StoragePoolId"]);
    $w->characters ("00000000-0000-0000-0000-000000000000");
    $w->endTag ();
    $w->startTag ([$rasd_ns, "CreationDate"]);
    $w->characters ($iso_time);
    $w->endTag ();
    $w->startTag ([$rasd_ns, "LastModified"]);
    $w->characters ($iso_time);
    $w->endTag ();
    $w->startTag ([$rasd_ns, "last_modified_date"]);
    $w->characters ($iso_time);
    $w->endTag ();

    $w->endTag ("Item");
}

$w->endTag ("Section"); # ovf:VirtualHardwareSection_Type

$w->endTag ("Content");

$w->endTag ([$ovf_ns, "Envelope"]);
$w->end ();

#print "OVF:\n$ovf\n";

my $ovf_dir = "$esd_uuid_dir/master/vms/$vm_uuid";
run_as_vdsm (sub {
    mkdir ($ovf_dir, 0755) or die "mkdir: $ovf_dir: $!";
});
my $ovf_file = "$ovf_dir/$vm_uuid.ovf";
run_as_vdsm (sub {
    open (my $fh, ">", $ovf_file) or die "open: $ovf_file: $!";
    print $fh $ovf
});

# Finished.
$delete_output_on_exit = 0;
print "\n";
print "OVF written to $ovf_file\n";
print "\n";
print "Import finished without errors.  Now go to the Storage tab ->\n";
print "Export Storage Domain -> VM Import, and import the guest.\n";
exit 0;

__END__

=head1 TO DO

=over 4

=item Network

Add a network card to the OVF.  The problem is detecting what
network devices the guest can support.

=item Disk model

Detect what disk models (eg. IDE, virtio-blk, virtio-scsi) the
guest can support and add the correct type of disk.

=back

=head1 DEBUGGING IMPORT FAILURES

When you export to the ESD, and then import that guest through the
oVirt / RHEV-M UI, you may encounter an import failure.  Diagnosing
these failures is infuriatingly difficult as the UI generally hides
the true reason for the failure.

There are two log files of interest.  The first is stored on the oVirt
engine / RHEV-M server itself, and is called
F</var/log/ovirt-engine/engine.log>

The second file, which is the most useful, is found on the SPM host
(SPM stands for "Storage Pool Manager").  This is a oVirt node that is
elected to do all metadata modifications in the data center, such as
image or snapshot creation.  You can find out which host is the
current SPM from the "Hosts" tab "Spm Status" column.  Once you have
located the SPM, log into it and grab the file
F</var/log/vdsm/vdsm.log> which will contain detailed error messages
from low-level commands.

=head1 SEE ALSO

L<https://bugzilla.redhat.com/show_bug.cgi?id=998279>,
L<https://bugzilla.redhat.com/show_bug.cgi?id=1049604>,
L<virt-v2v(1)>,
L<engine-image-uploader(8)>.

=head1 AUTHOR

Richard W.M. Jones <rjones@redhat.com>

=head1 COPYRIGHT

Copyright (C) 2015 Richard W.M. Jones <rjones@redhat.com>

Copyright (C) 2015 Red Hat Inc.

=head1 LICENSE

This program is free software; you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the
Free Software Foundation; either version 2 of the License, or (at your
option) any later version.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
General Public License for more details.

You should have received a copy of the GNU General Public License along
with this program; if not, write to the Free Software Foundation, Inc.,
51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
