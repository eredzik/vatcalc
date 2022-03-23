/**
 * This file contains the root router of your tRPC-backend
 */
import { createRouter } from "../createRouter";
import { enterprisesRouter } from "./enterprises";
import { invoicesRouter } from "./invoices";
import { trade_partners_router } from "./trade_partners";

/**
 * Create your application's root router
 * If you want to use SSG, you need export this
 * @link https://trpc.io/docs/ssg
 * @link https://trpc.io/docs/router
 */
export const appRouter = createRouter()
  .merge("enterprises.", enterprisesRouter)
  .merge("invoices.", invoicesRouter)
  .merge("trade_partners.", trade_partners_router);

export type AppRouter = typeof appRouter;
