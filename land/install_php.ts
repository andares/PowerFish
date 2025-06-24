import { CommandHandler } from "./main.ts";

export const installPhp: CommandHandler = (_args: string[]): number => {
  console.log("php is installing");
  return 0;
};
