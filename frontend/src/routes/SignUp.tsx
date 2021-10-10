import { CircularProgress } from "@material-ui/core";
import Avatar from "@material-ui/core/Avatar";
import Button from "@material-ui/core/Button";
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
import { Redirect } from "react-router";
import * as yup from "yup";
import { useRegisterUser, useUser } from "../hooks/userApi";
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
    marginTop: theme.spacing(3),
  },
  submit: {
    margin: theme.spacing(3, 0, 2),
  },
}));

export default function SignUp() {
  const user = useUser();
  const registerUser = useRegisterUser();
  const formik = useFormik({
    initialValues: {
      username: "",
      password: "",
      email: ""
    },
    validationSchema: yup.object({

    }),
    onSubmit: (values) => {
      registerUser.mutate(values);
    },
    validateOnMount: true
  });
  function getErrorMessage(error: AxiosError) {
    console.log(error.response)
    if (!error.response) {
      return "Błąd komunikacji z serwerem."
    } else if (error.response.status === 422) {
      return "Login już używany"
    } else if (error.response.status === 409) {
      return "Login lub email są już używane."
    } else {
      return "Nieznany błąd"
    }
  }

  const classes = useStyles();
  console.log(registerUser)
  return (
    <Container component="main" maxWidth="xs">
      <CssBaseline />
      <div className={classes.paper}>
        <Avatar className={classes.avatar}>
          <LockOutlinedIcon />
        </Avatar>
        <Typography component="h1" variant="h5">
          Zarejestruj się
        </Typography>
        <form className={classes.form} noValidate>
          <Grid container spacing={2}>
            <Grid item xs={12}>
              <TextField
                variant="outlined"
                required
                fullWidth
                id="username"
                label="Nazwa użytkownika"
                name="username"
                autoComplete="username"
                value={formik.values.username}
                onChange={formik.handleChange}
              />
            </Grid>
            <Grid item xs={12}>
              <TextField
                variant="outlined"
                required
                fullWidth
                id="email"
                label="Adres Email"
                name="email"
                autoComplete="email"
                value={formik.values.email}
                onChange={formik.handleChange}
              />
            </Grid>
            <Grid item xs={12}>
              <TextField
                variant="outlined"
                required
                fullWidth
                name="password"
                label="Hasło"
                type="password"
                id="password"
                autoComplete="current-password"

                value={formik.values.password}
                onChange={formik.handleChange}
              />
            </Grid>
            <Grid item xs={12}>
              <FormControlLabel
                control={<Checkbox value="allowExtraEmails" color="primary" />}
                label="Jakiś checkbox."
              />
            </Grid>
          </Grid>
          {registerUser.isError && (
            < Alert severity="error">{getErrorMessage((registerUser.error as AxiosError))}</Alert>
          )}
          <Button
            type="button"
            fullWidth
            variant="contained"
            color="primary"
            className={classes.submit}
            onClick={e => formik.handleSubmit()}
          >
            {(!registerUser.isLoading) && "Zarejestruj się"}
            {registerUser.isLoading && <CircularProgress color="secondary" size={24} />}
          </Button>
          <Grid container justifyContent="flex-end">
            <Grid item>
              <Link href="/login" variant="body2">
                Poziadasz już konto? Zaloguj się
              </Link>
            </Grid>
          </Grid>
        </form>
        {registerUser.isSuccess && <Redirect to="/" />}
        {user.isSuccess && <Redirect to="/" />}
      </div>
    </Container >
  );
}