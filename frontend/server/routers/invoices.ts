import { createProtectedRouter } from "../createProtectedRouter";
import { z } from "zod";
export const invoicesRouter = createProtectedRouter()
  .query("getEnterpriseInvoicesSummary", {
    input: z.object({ enterprise_id: z.number() }),
    async resolve({ ctx, input }) {
      if (
        await ctx.prisma.userEnterprise.findMany({
          where: { user_id: ctx.session.user.id },
          include: { enterprise: true },
        })
      ) {
        return await ctx.prisma.invoice.findMany({
          where: { enterprise_id: input.enterprise_id },
          include: { tradingpartner: true },
        });
      }
    },
  })
  .mutation("addInvoice", {
    input: z.object({
      invoice_business_id: z.string(),
      issue_date: z.date(),
      received_date: z.date(),
      invoice_type: z.string(),
    }),
    async resolve({ ctx, input }) {
      return await ctx.prisma.invoice.create({
        data: {
          invoice_business_id: input.invoice_business_id,
          issue_date: input.issue_date,
          received_date: input.received_date,
          invoice_type: input.invoice_type,
        },
      });
    },
  });
