import { TRPCError } from "@trpc/server";
import { z } from "zod";
import { createProtectedRouter } from "../createProtectedRouter";

export const enterprisesRouter = createProtectedRouter()
  .query("availableEnterprises", {
    async resolve({ ctx }) {
      return await ctx.prisma.userEnterprise.findMany({
        where: { user_id: ctx.session.user.id },
        include: { enterprise: true },
      });
    },
  })
  .mutation("setFavEnterprise", {
    input: z.object({ enterprise_id: z.number() }),
    async resolve({ ctx, input }) {
      const user = await ctx.prisma.user.findUnique({
        where: { id: ctx.session.user.id },
        include: {
          userenterprise: { where: { enterprise_id: input.enterprise_id } },
        },
      });
      if (user && user.userenterprise.length > 0) {
        return await ctx.prisma.user.update({
          where: { id: user.id },
          data: { fav_enterprise_id: input.enterprise_id },
        });
      } else {
        throw new TRPCError({ code: "UNAUTHORIZED" });
      }
    },
  })
  .query("listVatrates", {
    input: z.object({
      enterprise_id: z.number(),
    }),
    async resolve({ ctx, input }) {
      return await ctx.prisma.vatRate.findMany({
        where: { enterprise_id: input.enterprise_id },
      });
    },
  })
  .mutation("addEnterprise", {
    input: z.object({
      address: z.string(),
      nip_number: z.string(),
      name: z.string(),
    }),
    async resolve({ ctx, input }) {
      const user_id = ctx.session.user.id;
      console.log(ctx.session);
      return await ctx.prisma.enterprise.create({
        data: {
          address: input.address,
          name: input.name,
          nip_number: input.nip_number,
          userenterprise: {
            create: [
              {
                role: "ADMIN1",
                user_id: user_id,
              },
            ],
          },
        },
      });
    },
  });
