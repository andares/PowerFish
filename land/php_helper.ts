import { colors } from "@cliffy/ansi/colors";
import { tty } from "@cliffy/ansi/tty";
import { delay } from "@std/async/delay";

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

try {
  // 使用Web API fetch发起请求
  const response = await fetch("https://www.php.net/releases/?json&max=1&version=8");
  if (!response.ok) throw new Error(`请求失败，状态码：${response.status}`);

  // 使用Web API解析JSON
  const data = await response.json();

  // 动态获取第一个版本信息（适应不同版本号结构）
  const [versionKey] = Object.keys(data);
  if (!versionKey) throw new Error("未找到版本信息");
  const { source } = data[versionKey];

  // 使用Web API Array.prototype.find查找.xz文件
  const xzFile = source?.find((item: { filename: string }) =>
    item.filename.endsWith(".xz")
  );

  if (!xzFile) throw new Error("未找到.xz后缀文件");
  console.log(xzFile.filename);

} catch (err) {
  if (err instanceof Error) console.error("错误：", err.message);
}
