set hostname = jmutai.com
set mail_check = 120
set timeout = 300
set imap_user="m@jmutai.com"
set imap_pass=$my_jmutai_pw
set from=m@jmutai.com
set realname = 'Josphat Mutai'
set folder="imaps://jmutai.com/"
set postponed="=Drafts"
set spoolfile="imap://jmutai.com/INBOX"
set signature="~/.mutt/signature.m.jmutai.com"
set use_from = yes
set smtp_url=smtps://$imap_user:$imap_pass@$hostname
set ssl_force_tls = yes

