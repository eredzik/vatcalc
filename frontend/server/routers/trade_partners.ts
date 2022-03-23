import { createProtectedRouter } from "../createProtectedRouter";
import { z } from "zod";
export const trade_partners_router = createProtectedRouter()
  .query("getTradePartners", {
    input: z.object({ enterprise_id: z.number() }),
    async resolve({ ctx, input }) {
      if (
        await ctx.prisma.userEnterprise.findMany({
          where: { user_id: ctx.session.user.id },
          include: { enterprise: true },
        })
      ) {
        return await ctx.prisma.tradingPartner.findMany({
          where: { enterprise_id: input.enterprise_id },
        });
      }
    },
  })
  .mutation("addTradePartner", {
    input: z.object({
      name: z.string(),
      nip_number: z.string(),
      address: z.string(),
    }),
    async resolve({ ctx, input }) {
      return await ctx.prisma.tradingPartner.create({
        data: { ...input, enterprise_id: ctx.session.user.fav_enterprise_id },
      });
    },
  });
