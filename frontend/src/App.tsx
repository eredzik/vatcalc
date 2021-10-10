import { Backdrop, CircularProgress } from "@material-ui/core";
import { useEffect } from "react";
import { useQueryClient } from 'react-query';
import { BrowserRouter as Router, Route, Switch } from "react-router-dom";
import { Navbar } from "./components/Navbar";
import { useUser } from "./hooks/userApi";
import Dashboard from "./routes/Dashboard";
import EnterprisesAdd from "./routes/Enterprises/Add";
import Home from "./routes/Home";
import { InvoiceAdd } from "./routes/Invoices/Add";
import { InvoicesList } from "./routes/Invoices/List";
import SignIn from "./routes/SignIn";
import SignUp from "./routes/SignUp";
import AddTradingPartner from "./routes/TradingPartners/Add";
import TradingPartnersList from "./routes/TradingPartners/List";

export const App: React.FC<{
}> = () => {
  const queryClient = useQueryClient()
  useEffect(
    () => {
      queryClient.invalidateQueries('user');
    },
    []);

  const user = useUser();
  return (
    <Router>
      <Backdrop open={user.isLoading}>
        <CircularProgress color="inherit" />
      </Backdrop>
      <Navbar />
      <Switch>
        <Route component={Home} exact path="/" />
        <Route component={SignIn} exact path="/login" />
        <Route component={SignUp} exact path="/register" />
        <Route component={Dashboard} exact path="/dashboard" />
        <Route component={EnterprisesAdd} exact path="/enterprise/add" />
        <Route component={TradingPartnersList} exact path="/trading_partner" />
        <Route component={AddTradingPartner} exact path="/trading_partner/add" />
        <Route component={InvoiceAdd} exact path="/invoice/add" />
        <Route component={InvoicesList} exact path="/invoice" />

        <Route component={Home} />
      </Switch>
    </Router>
  );
};
export default App;
