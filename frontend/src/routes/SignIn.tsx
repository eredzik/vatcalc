import Avatar from "@material-ui/core/Avatar";
import Checkbox from "@material-ui/core/Checkbox";
import Container from "@material-ui/core/Container";
import CssBaseline from "@material-ui/core/CssBaseline";
import FormControlLabel from "@material-ui/core/FormControlLabel";
import Grid from "@material-ui/core/Grid";
import Link from "@material-ui/core/Link";
import { makeStyles } from "@material-ui/core/styles";
import TextField from "@material-ui/core/TextField";
import Typography from "@material-ui/core/Typography";
import LockOutlinedIcon from "@material-ui/icons/LockOutlined";
import { Alert } from "@material-ui/lab";
import { AxiosError } from "axios";
import { useFormik } from "formik";
import { Redirect, useHistory } from "react-router";
import { Link as RouterLink } from "react-router-dom";
import * as yup from "yup";
import { useLoginUser, useUser } from "../hooks/userApi";
import { Button } from "semantic-ui-react"
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
  const user = useUser();
  const history = useHistory();
  console.log(user)
  if (user.isSuccess) {
    history.replace("/")
  }
  const loginUser = useLoginUser();

  const classes = useStyles();
  const formik = useFormik({
    initialValues: {
      username: "",
      password: "",
    },
    validationSchema: yup.object({
      username: yup.string().required(),
      password: yup.string().required()
    }),
    onSubmit: (values) => {
      loginUser.mutate(values);
    },
    validateOnMount: true
  });
  function getErrorString(error: AxiosError) {
    console.log(loginUser.error as AxiosError)
    if (error.response?.status === 401) {
      return "Zły login lub hasło"
    } else {
      return "Nieznany błąd serwera"
    }

  }
  return (
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
            onChange={formik.handleChange}
            onBlur={formik.handleBlur}
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
            error={!!formik.errors.password}
            autoComplete="current-password"
            onChange={formik.handleChange}
            onBlur={formik.handleBlur}
          />
          <FormControlLabel
            control={<Checkbox value="remember" color="primary" />}
            label="Zapamiętaj mnie"
          />
          {loginUser.isError && (
            <Alert severity="error">{getErrorString(loginUser.error as AxiosError)}</Alert>
          )}
          <Button
            type="button"
            primary
            className={classes.submit}
            onClick={() => formik.handleSubmit()}
            isLoading={loginUser.isLoading}
          >
            Zaloguj się"
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
        </form>
      </div>
      {loginUser.isSuccess && <Redirect to="/" />}

    </Container>
  );
}
