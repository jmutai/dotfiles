// Every Go program starts with a package declaration which provides a way for
// use to reuse code
package main

// import allows use to use code from other packages
// The format package provides formatting for input and output
import "fmt"

// A comment

/*
Multiline Comment
*/

// Functions start with func and surround the code with { }
// main is the function that is executed when you execute your program

func main() {

	// Println is a function in the fmt package that outputs a string, which
	// is surrounded by double quotes and a newline to the screen
	
	fmt.Println("Hello World")
	
	// You can get a description of a function by typing godoc fmt Println
	// for example in the terminal
	
	// You execute Go programs like this in the terminal go run herewego.go
	
	// Variables are statically typed, which means their type can't change
	// Variable names must start with a letter and may contain letters, numbers
	// or the _
	
	// An int is a positive or negative number without decimals
	// Versions 
	// uint8 : unsigned  8-bit integers (0 to 255)
	// uint16 : unsigned 16-bit integers (0 to 65535)
	// uint32 : unsigned 32-bit integers (0 to 4294967295)
	// uint64 : unsigned 64-bit integers (0 to 18446744073709551615)
	// int8 : signed  8-bit integers (-128 to 127)
	// int16 : signed 16-bit integers (-32768 to 32767)
	// int32 : signed 32-bit integers (-2147483648 to 2147483647)
	// int64 : signed 64-bit integers (-9223372036854775808 to 
	// 9223372036854775807)
	
	var age int64 = 40
	
	// A float is a number with decimals
	// Versions : float32, float64
	
	var favNum float64 = 1.61803398875
	
	// You don't need to define the data type, nor do you need a semicolon
	// but you can use them
	
	randNum := 1;
	fmt.Println(randNum);
	
	// You can't however assign a non-compatible type later
	
	// randNum = "Hello"
	
	// You can use variables in Println (Space is automatically added)
	
	fmt.Println(age, " ", favNum)
	
	var numOne = 1.000
	var num99 = .999
	
	// You can perform arithmetic in Println (Note that floats aren't accurate)
	
	fmt.Println(numOne - num99)
	
	// Arithmetic Operators : +, -, *, /, %
	
	fmt.Println("6 + 4 =", 6 + 4)
	fmt.Println("6 - 4 =", 6 - 4)
	fmt.Println("6 * 4 =", 6 * 4)
	fmt.Println("6 / 4 =", 6 / 4)
	fmt.Println("6 % 4 =", 6 % 4)

}
