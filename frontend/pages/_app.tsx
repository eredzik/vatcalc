import { AppProps } from "next/app";
import { withTRPC } from "@trpc/next";
import { AppRouter } from "../server/routers/_app";
import superjson from "superjson";
import { SessionProvider, signIn, useSession } from "next-auth/react";
import "semantic-ui-css/semantic.min.css";
import { ReactNode } from "react";
import React from "react";
type AppPropsWithProtection = AppProps & { Component: { auth: Boolean } };

function Auth({ children }: { children: JSX.Element }) {
  const { data: session, status } = useSession({ required: true });
  const isUser = !!session?.user;
  React.useEffect(() => {
    if (status === "loading") return;
    if (!isUser) signIn();
  }, [isUser, status]);

  if (isUser) {
    return children;
  }

  // Session is being fetched, or no user.
  // If no user, useEffect() will redirect.
  return <div>Loading...</div>;
}
const App = ({
  Component,
  pageProps: { session, ...pageProps },
}: AppPropsWithProtection) => {
  return (
    <SessionProvider session={session}>
      {Component.auth ? (
        <Auth>
          <Component {...pageProps} />
        </Auth>
      ) : (
        <Component {...pageProps} />
      )}
    </SessionProvider>
  );
};

export default withTRPC<AppRouter>({
  config({ ctx }) {
    /**
     * If you want to use SSR, you need to use the server's full URL
     * @link https://trpc.io/docs/ssr
     */
    const url = process.env.VERCEL_URL
      ? `https://${process.env.VERCEL_URL}/api/trpc`
      : "http://localhost:3000/api/trpc";

    return {
      url,
      transformer: superjson,
      /**
       * @link https://react-query.tanstack.com/reference/QueryClient
       */
      // queryClientConfig: { defaultOptions: { queries: { staleTime: 60 } } },
    };
  },
  /**
   * @link https://trpc.io/docs/ssr
   */
  ssr: true,
})(App);
// export default App;
