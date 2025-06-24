import { assertEquals } from "@std/assert";
import { CommandRouter, type CommandHandler } from "./main.ts";
import { spy } from "@std/testing/mock";

// Mock command handler for testing
const createMockHandler = (result: number): [CommandHandler, any] => {
  const mockFn = spy((_args: string[]) => result);
  return [mockFn as unknown as CommandHandler, mockFn];
};

Deno.test("CommandRouter registers and routes commands correctly", async () => {
  const router = new CommandRouter();
  const [mockHandler, mockSpy] = createMockHandler(0);

  router.register("test", "Test command description", mockHandler);
  const exitCode = await router.route(["test"]);

  assertEquals(exitCode, 0);
  assertEquals(mockSpy.calls[0].args[0], []);
});

Deno.test("CommandRouter handles unknown commands", async () => {
  const router = new CommandRouter();
  const [mockHandler, mockSpy] = createMockHandler(0);

  router.register("known", "Known command description", mockHandler);
  const exitCode = await router.route(["unknown"]);

  assertEquals(exitCode, 1);
  assertEquals(mockSpy.calls.length, 0);
});

Deno.test("CommandRouter passes arguments to handlers", async () => {
  const router = new CommandRouter();
  const [mockHandler, mockSpy] = createMockHandler(0);

  router.register("test", "Test command description", mockHandler);
  await router.route(["test", "arg1", "arg2"]);

  assertEquals(mockSpy.calls[0].args[0], ["arg1", "arg2"]);
});

Deno.test("CommandRouter shows help correctly", () => {
  const router = new CommandRouter();
  const [mockHandler] = createMockHandler(0);
  const consoleSpy = spy(console, "log");

  router.register("cmd1", "Command 1 description", mockHandler);
  router.register("cmd2", "Command 2 description", mockHandler);
  router.showHelp();

  assertEquals(consoleSpy.calls[0].args[0], "Available commands:");
  assertEquals(consoleSpy.calls[1].args[0], "  cmd1");
  assertEquals(consoleSpy.calls[2].args[0], "  cmd2");

  consoleSpy.restore();
});

Deno.test("CommandRouter handles handler errors", async () => {
  const router = new CommandRouter();
  const errorHandler: CommandHandler = () => {
    throw new Error("Test error");
  };
  const consoleErrorSpy = spy(console, "error");

  router.register("error", "Error command description", errorHandler);
  const exitCode = await router.route(["error"]);

  assertEquals(exitCode, 1);
  assertEquals(consoleErrorSpy.calls[0].args[0], "Error executing command 'error':");

  consoleErrorSpy.restore();
});
