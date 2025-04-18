import { colors } from "jsr:@cliffy/ansi/colors";
import { tty } from "jsr:@cliffy/ansi/tty";
import { delay } from "jsr:@std/async/delay";

const error = colors.bold.red;
const warn = colors.bold.yellow;
const info = colors.bold.blue;

console.log(info("This is an info message!"));
console.log(warn("This is a warning!"));
console.log(error("This is an error message!"));
console.log(error.underline("This is a critical error message!"));

await delay(3000);

tty.cursorLeft.cursorUp(4).eraseDown();


// https://www.php.net/releases/?json&max=1&version=8

