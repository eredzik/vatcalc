import { Container } from "semantic-ui-react";
import { Navbar } from "./Navbar";

export const Layout: React.FC<{}> = ({ children }) => {
  return (
    <>
      <Navbar />
      <Container style={{ marginTop: "2em" }}>{children}</Container>
    </>
  );
};
