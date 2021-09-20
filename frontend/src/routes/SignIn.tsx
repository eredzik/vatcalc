import Avatar from "@material-ui/core/Avatar";
import Button from "@material-ui/core/Button";
import CssBaseline from "@material-ui/core/CssBaseline";
import TextField from "@material-ui/core/TextField";
import FormControlLabel from "@material-ui/core/FormControlLabel";
import Checkbox from "@material-ui/core/Checkbox";
import Link from "@material-ui/core/Link";
import Grid from "@material-ui/core/Grid";
import LockOutlinedIcon from "@material-ui/icons/LockOutlined";
import Typography from "@material-ui/core/Typography";
import { makeStyles } from "@material-ui/core/styles";
import Container from "@material-ui/core/Container";
import { Alert } from "@material-ui/lab";
import { AuthenticationApi, UserApi } from "../generated";
import { useReducer } from "react";
import { Redirect } from "react-router";
import { useCallback } from "react";
import CircularProgress from "@material-ui/core/CircularProgress";
import { AxiosError } from "axios";
import { apiConfig } from "../api";
import { useAppDispatch, useAppSelector } from "../redux/selectors";
import { Link as RouterLink } from "react-router-dom";
import { updateUser } from "../redux/userSlice";
const useStyles = makeStyles((theme) => ({
  paper: {
    marginTop: theme.spacing(8),
    display: "flex",
    flexDirection: "column",
    alignItems: "center",
  },
  avatar: {
    margin: theme.spacing(1),
    backgroundColor: theme.palette.secondary.main,
  },
  form: {
    width: "100%", // Fix IE 11 issue.
    marginTop: theme.spacing(1),
  },
  submit: {
    margin: theme.spacing(3, 0, 2),
  },
}));

export default function SignIn() {
  interface SignInState {
    username: string;
    usernameError: string | null;
    password: string;
    passwordError: string | null;
    errorString: String | null;
    loading: boolean;
    response: number | undefined;
    redirect: JSX.Element | null;
  }
  const initialSignInState: SignInState = {
    username: "",
    usernameError: null,
    password: "",
    passwordError: null,
    errorString: "",
    loading: false,
    response: undefined,
    redirect: null,
  };

  enum ActionKind {
    InputUsername,
    BlurInputUsername,
    InputPassword,
    BlurInputPassword,
    ClickedSignInButton,
    ReceivedResponse,
  }
  type SignInAction =
    | { type: ActionKind.InputPassword; password: string }
    | { type: ActionKind.BlurInputPassword }
    | { type: ActionKind.InputUsername; username: string }
    | { type: ActionKind.BlurInputUsername }
    | { type: ActionKind.ClickedSignInButton }
    | { type: ActionKind.ReceivedResponse; response: number | undefined };

  const classes = useStyles();
  const dispatch_redux = useAppDispatch()

  const memoizedReducer = useCallback(signInReducer, []);
  function signInReducer(
    state: SignInState,
    action: SignInAction
  ): SignInState {
    switch (action.type) {
      case ActionKind.InputPassword:
        return { ...state, password: action.password };
      case ActionKind.BlurInputPassword:
        return { ...state, errorString: null };
      case ActionKind.InputUsername:
        return { ...state, username: action.username };
      case ActionKind.BlurInputUsername:
        return { ...state, errorString: null };
      case ActionKind.ClickedSignInButton: {
        if (state.loading !== true) {
          new AuthenticationApi(apiConfig)
            .loginUserLoginPost({
              username: state.username,
              password: state.password,
            })
            .then(() =>
              new UserApi(apiConfig).getUserDataUserMeGet().then(
                res => {
                  dispatch_redux(updateUser(res.data));
                  dispatch({
                    type: ActionKind.ReceivedResponse,
                    response: res.status,
                  })
                }
              ).catch(
                e => {
                  console.log(e);
                  dispatch({
                    type: ActionKind.ReceivedResponse,
                    response: e.response?.status,
                  })
                })
            )
            .catch((e: AxiosError) =>
              dispatch({
                type: ActionKind.ReceivedResponse,
                response: e.response?.status,
              })
            );
        }

        return { ...state, loading: true };
      }
      case ActionKind.ReceivedResponse:
        console.log(action.response);
        if (action.response === 204) {
          return {
            ...state,
            response: action.response,
            redirect: <Redirect to="/" />,
          };
        } else if (action.response === 401) {
          return {
            ...state,
            loading: false,
            response: action.response,
            errorString: "Błędny login lub hasło",
          };
        } else {
          return { ...state, response: action.response };
        }
    }
  }
  const user = useAppSelector(state => state.user.user)
  const [state, dispatch] = useReducer(memoizedReducer, initialSignInState);
  return user ? (
    <Redirect to={"/"} />
  ) : (
    <Container component="main" maxWidth="xs">
      <CssBaseline />
      <div className={classes.paper}>
        <Avatar className={classes.avatar}>
          <LockOutlinedIcon />
        </Avatar>
        <Typography component="h1" variant="h5">
          Zaloguj się
        </Typography>
        <form className={classes.form}>
          <TextField
            variant="outlined"
            margin="normal"
            required
            fullWidth
            id="username"
            label="Nazwa użytkownika"
            name="username"
            autoComplete="username"
            onChange={(event) =>
              dispatch({
                type: ActionKind.InputUsername,
                username: event.target.value,
              })
            }
            onBlur={() => dispatch({ type: ActionKind.BlurInputUsername })}
            autoFocus
          />
          <TextField
            variant="outlined"
            margin="normal"
            required
            fullWidth
            name="password"
            label="Hasło"
            type="password"
            id="password"
            autoComplete="current-password"
            onChange={(e) =>
              dispatch({
                type: ActionKind.InputPassword,
                password: e.target.value,
              })
            }
            onBlur={() => dispatch({ type: ActionKind.BlurInputPassword })}
          />
          <FormControlLabel
            control={<Checkbox value="remember" color="primary" />}
            label="Zapamiętaj mnie"
          />
          {state.errorString && (
            <Alert severity="error">{state.errorString}</Alert>
          )}
          <Button
            type="button"
            fullWidth
            variant="contained"
            color="primary"
            disabled={state.loading}
            className={classes.submit}
            onClick={function (e) {
              e.preventDefault();
              dispatch({ type: ActionKind.ClickedSignInButton });
            }}
          >
            {!state.loading && "Zaloguj się"}
            {state.loading && <CircularProgress color="secondary" size={24} />}
          </Button>

          <Grid container>
            <Grid item xs>
              <Link to="/restore-password" variant="body2" component={RouterLink}>
                Zapomniałeś hasła?
              </Link>
            </Grid>
            <Grid item>
              <Link to="/register" variant="body2" component={RouterLink}>
                {"Nie masz konta? Zarejestruj się"}
              </Link>
            </Grid>
          </Grid>
          {state.redirect}
        </form>
      </div>
    </Container>
  );
}
