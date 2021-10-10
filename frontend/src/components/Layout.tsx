import { Container } from "semantic-ui-react";

export const Layout: React.FC<{}> = ({ children }) => {
    return (
        <Container style={{ marginTop: "2em" }}>
            {children}
        </Container>)
}
