import { Grid } from "@material-ui/core";
import { useEffect } from "react";

export default function Home() {
    useEffect(() => {
        document.title = "VatCalc";
    }, []);

    return (
        <Grid container alignItems="center">
            <h1>Witaj w VATCalc</h1>
        </Grid>
    )
}