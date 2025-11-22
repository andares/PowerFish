// [ ]: 未实装进入land系统
import { parse } from "https://deno.land/std@0.200.0/flags/mod.ts";

// 中文字符的 Unicode 范围
const CHINESE_CHAR_REGEX = /[\u4e00-\u9fff\u3400-\u4dbf\uf900-\ufaff]/g;
const CHINESE_PUNCTUATION_REGEX = /[\u3000-\u303f\uff00-\uffef]/g;
const CHINESE_NUMBERS_REGEX = /[〇一二三四五六七八九十百千万亿]/g;

interface RemoveOptions {
  inputFile?: string;
  outputFile?: string;
  removePunctuation: boolean;
  removeNumbers: boolean;
  verbose: boolean;
  help: boolean;
}

function printHelp(): void {
  console.log(`
去除文件中UTF-8中文字符的工具

使用方法:
  deno run --allow-read --allow-write remove_chinese.ts [选项]

选项:
  -i, --input <文件>        输入文件路径 (必需)
  -o, --output <文件>       输出文件路径 (必需)
  -p, --punctuation         同时移除中文标点符号
  -n, --numbers             同时移除中文数字
  -v, --verbose             显示详细处理信息
  -h, --help                显示此帮助信息

示例:
  deno run --allow-read --allow-write remove_chinese.ts -i input.txt -o output.txt
  deno run --allow-read --allow-write remove_chinese.ts --input=input.txt --output=output.txt --punctuation --verbose
  deno run --allow-read --allow-write remove_chinese.ts -i input.txt -o output.txt -pnv
`);
}

function parseArguments(args: string[]): RemoveOptions {
  const parsed = parse(args, {
    string: ["input", "output"],
    boolean: ["punctuation", "numbers", "verbose", "help"],
    alias: {
      input: "i",
      output: "o",
      punctuation: "p",
      numbers: "n",
      verbose: "v",
      help: "h"
    },
    default: {
      punctuation: false,
      numbers: false,
      verbose: false,
      help: false
    },
    "--": true
  });

  return {
    inputFile: parsed.input,
    outputFile: parsed.output,
    removePunctuation: parsed.punctuation,
    removeNumbers: parsed.numbers,
    verbose: parsed.verbose,
    help: parsed.help
  };
}

function removeChineseContent(content: string, options: Omit<RemoveOptions, "inputFile" | "outputFile" | "help" | "verbose">): { cleanedContent: string; removedCount: number } {
  let result = content;
  let totalRemoved = 0;

  // 移除基本中文字符
  const basicRemoved = result.replace(CHINESE_CHAR_REGEX, '');
  totalRemoved += result.length - basicRemoved.length;
  result = basicRemoved;

  // 可选：移除中文标点
  if (options.removePunctuation) {
    const punctuationRemoved = result.replace(CHINESE_PUNCTUATION_REGEX, '');
    totalRemoved += result.length - punctuationRemoved.length;
    result = punctuationRemoved;
  }

  // 可选：移除中文数字
  if (options.removeNumbers) {
    const numbersRemoved = result.replace(CHINESE_NUMBERS_REGEX, '');
    totalRemoved += result.length - numbersRemoved.length;
    result = numbersRemoved;
  }

  return {
    cleanedContent: result,
    removedCount: totalRemoved
  };
}

async function processFile(options: RemoveOptions): Promise<void> {
  if (options.help) {
    printHelp();
    return;
  }

  // 验证必需参数
  if (!options.inputFile || !options.outputFile) {
    console.error("错误: 必须指定输入文件和输出文件");
    console.log("使用 --help 查看使用方法");
    Deno.exit(1);
  }

  try {
    // 读取输入文件
    if (options.verbose) {
      console.log(`读取输入文件: ${options.inputFile}`);
    }

    const content = await Deno.readTextFile(options.inputFile);
    const originalLength = content.length;

    if (options.verbose) {
      console.log(`文件大小: ${originalLength} 字符`);
    }

    // 移除中文字符
    const { cleanedContent, removedCount } = removeChineseContent(content, {
      removePunctuation: options.removePunctuation,
      removeNumbers: options.removeNumbers
    });

    // 写入输出文件
    if (options.verbose) {
      console.log(`写入输出文件: ${options.outputFile}`);
    }

    await Deno.writeTextFile(options.outputFile, cleanedContent);

    // 输出处理结果
    console.log(`✅ 文件处理完成:`);
    console.log(`   输入: ${options.inputFile}`);
    console.log(`   输出: ${options.outputFile}`);
    console.log(`   移除了 ${removedCount} 个中文字符`);
    console.log(`   剩余 ${cleanedContent.length} 个字符`);

    if (options.verbose) {
      const percentage = ((removedCount / originalLength) * 100).toFixed(2);
      console.log(`   移除比例: ${percentage}%`);
    }

  } catch (error) {
    console.error(`❌ 处理文件时出错: ${error.message}`);
    Deno.exit(1);
  }
}

// 主函数
async function main(): Promise<void> {
  const options = parseArguments(Deno.args);
  await processFile(options);
}

// 运行脚本
if (import.meta.main) {
  await main();
}