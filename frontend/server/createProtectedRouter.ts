import { TRPCError } from "@trpc/server";
import { Session } from "next-auth";
import { any } from "zod";
import { trpc } from "../utils/trpc";
import { createRouter } from "./createRouter";

export function createProtectedRouter() {
  return createRouter().middleware(({ ctx, next }) => {
    if (ctx.session) {
    } else {
      throw new TRPCError({
        code: "FORBIDDEN",
        message: "Użytkownik nie jest zalogowany",
      });
    }

    return next({ ctx: { ...ctx, session: ctx.session } });
  });
}
