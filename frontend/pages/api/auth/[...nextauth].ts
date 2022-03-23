import NextAuth, { Session, User } from "next-auth";
import GithubProvider from "next-auth/providers/github";
import { PrismaClient } from "@prisma/client";
import { PrismaAdapter } from "@next-auth/prisma-adapter";

const prisma = new PrismaClient();
export default NextAuth({
  // Configure one or more authentication providers
  adapter: PrismaAdapter(prisma),
  providers: [
    GithubProvider({
      clientId: process.env.GITHUB_ID,
      clientSecret: process.env.GITHUB_SECRET,
    }),
    // ...add more providers here
  ],
  callbacks: {
    session: async ({ session, user }: { session: Session; user: User }) => {
      session.user.id = user.id;
      session.user.fav_enterprise_id = user.fav_enterprise_id as number;
      return session;
    }, // session({ session: Session, user }) {
    //     session.id = user.id
    //     return session
    // }
  },
});
