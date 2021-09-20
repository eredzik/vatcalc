import { BrowserRouter as Router, Switch, Route } from "react-router-dom";

import SignIn from "./routes/SignIn";
import Dashboard from "./routes/Dashboard";
import SignUp from "./routes/SignUp";
import Home from "./routes/Home";
import { Navbar } from "./components/Navbar";
import EnterprisesAdd from "./routes/Enterprises/Add";
import { useEffect } from "react";
import { useAppDispatch, useAppSelector } from "./redux/selectors";
import { fetchEnterprises } from "./redux/enterprisesSlice";
import { Backdrop, CircularProgress, createStyles, makeStyles, Theme } from "@material-ui/core";
import { fetchUser } from "./redux/userSlice";
const useStyles = makeStyles((theme: Theme) =>
  createStyles(
    {
      backdrop: {
        zIndex: theme.zIndex.drawer + 1,
        color: 'fff',
      }
    }
  ))

export const App: React.FC<{
}> = () => {
  const dispatch = useAppDispatch();
  const classes = useStyles();
  useEffect(
    (() => {
      dispatch(fetchUser());
      dispatch(fetchEnterprises())
    }),
    [dispatch])
  const loading = useAppSelector((state =>
    (state.user.loading === 'idle') ||
    (state.user.loading === 'pending') ||
    (state.enterprise.loading === 'idle') ||
    (state.enterprise.loading === 'pending')))
  console.log(loading)
  return (
    <Router>
      <Backdrop open={loading} className={classes.backdrop}>
        <CircularProgress color="inherit" />
      </Backdrop>
      <Navbar />
      <Switch>
        <Route component={Home} exact path="/" />
        <Route component={SignIn} exact path="/login" />
        <Route component={SignUp} exact path="/register" />
        <Route component={Dashboard} exact path="/dashboard" />
        <Route component={EnterprisesAdd} exact path="/enterprises/add" />
        <Route component={Home} />
      </Switch>
      s
    </Router>
  );
};
export default App;