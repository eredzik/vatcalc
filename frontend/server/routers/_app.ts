/**
 * This file contains the root router of your tRPC-backend
 */
import { createRouter } from "../createRouter";

/**
 * Create your application's root router
 * If you want to use SSG, you need export this
 * @link https://trpc.io/docs/ssg
 * @link https://trpc.io/docs/router
 */
export const appRouter = createRouter();

export type AppRouter = typeof appRouter;
