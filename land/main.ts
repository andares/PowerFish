import { colors } from "@cliffy/ansi/colors";
import { installPhp } from "./install_php.ts";

// Define exit codes for better maintainability
export enum ExitCode {
  Success = 0,
  GenericError = 1,
  InvalidCommand = 2,
  InvalidArguments = 3,
}

export type CommandHandler = (args: string[]) => Promise<number> | number;

export class CommandRouter {
  private commands: Map<string, { handler: CommandHandler; description: string }>;

  constructor() {
    this.commands = new Map();
  }

  register(command: string, description: string, handler: CommandHandler): void {
    this.commands.set(command, { handler, description });
  }

  async route(args: string[]): Promise<number> {
    // Validate input
    if (!Array.isArray(args)) {
      console.error(colors.red("Error: Invalid arguments - expected array"));
      return ExitCode.InvalidArguments;
    }

    if (args.length === 0) {
      console.error(colors.red("Error: No command specified"));
      this.showHelp();
      return ExitCode.InvalidCommand;
    }

    const [command, ...restArgs] = args;
    const commandData = this.commands.get(command);

    if (!commandData) {
      console.error(colors.red(`Error: Unknown command '${command}'`));
      this.showHelp();
      return ExitCode.InvalidCommand;
    }

    try {
      return await commandData.handler(restArgs);
    } catch (error) {
      console.error(colors.red(`Error executing command '${command}':`));
      console.error(error instanceof Error ? error.stack : error);
      return ExitCode.GenericError;
    }
  }

  public showHelp(): void {
    console.log(colors.bold("Available commands:"));
    console.log("");

    // Find longest command name for formatting
    let maxLength = 0;
    for (const cmd of this.commands.keys()) {
      if (cmd.length > maxLength) maxLength = cmd.length;
    }

    for (const [cmd, { description }] of this.commands.entries()) {
      console.log(`  ${colors.bold(cmd.padEnd(maxLength))}  ${description}`);
    }

    console.log("");
    console.log(`Run ${colors.bold("Land help <command>")} for more information on a command`);
  }
}

export const main = async (): Promise<number> => {
  const router = new CommandRouter();

  // Register default commands with descriptions
  router.register("help", "Show available commands", () => {
    router.showHelp();
    return ExitCode.Success;
  });

  // Register PHP installation command
  router.register("install-php", "Install PHP runtime", installPhp);

  return await router.route(Deno.args);
}

if (import.meta.main) {
  main().then((code) => Deno.exit(code));
}
