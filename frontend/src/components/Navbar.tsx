import {
  AppBar,
  Button,
  IconButton,
  Menu,
  MenuItem,
  Toolbar,
  Link,
  Select,
} from "@material-ui/core";
import React from "react";
import MenuIcon from "@material-ui/icons/Menu";
import { Link as RouterLink, Redirect } from "react-router-dom";
import { useState } from "react";
import { useAppDispatch, useAppSelector } from "../redux/selectors";
import { apiConfig } from "../api";
import { AuthenticationApi } from "../generated";
import { updateUser } from "../redux/userSlice";
import { Skeleton } from "@material-ui/lab";


export const Navbar: React.FC<{}> = () => {

  return (
    <AppBar position="static">
      <Toolbar color="red">
        <Link
          variant="h4"
          color="textPrimary"
          component={RouterLink}
          to="/"
          style={{
            textDecoration: "none",
            fontWeight: "bold",
            flexGrow: 1,
          }}
        >
          VatCalc
        </Link>
        <RightButton />
      </Toolbar>
    </AppBar>
  );
};


function SelectEnterprise(): JSX.Element {
  const user = useAppSelector((state) => state.user);
  const enterprises = useAppSelector((state) => state.enterprise.enterprises)
  const [redirect, setRedirect] = useState<JSX.Element | undefined>();

  const selectedEnterpriseId = user.user?.fav_enterprise_id || "";
  const AddEnterpriseItem = () => <MenuItem
    value={""}
    key={""}
    onClick={(e) => {
      setRedirect(<Redirect to="/enterprises/add" />);
    }}
  >
    Dodaj firmę
  </MenuItem>
  console.log(enterprises)
  const select_items = (
    enterprises.length
      ? (enterprises.map((item) =>
        < MenuItem
          key={item.enterprise_id}
          value={item.enterprise_id}
        >
          {item.name}</MenuItem>
      )) : null
  )
  return (
    <Select style={{ marginRight: 2 }} value={selectedEnterpriseId}
    // onChange={(e) => new UserApi(apiConfig)
    //   .updateEnterpriseUserMePreferredEnterprisePatch(e.target.value as number)
    //   .then(dispatch())
    //   }
    >
      {select_items}
      < AddEnterpriseItem />
      {redirect}
    </Select >
  );
}

function RightButton() {
  const [anchorEl, setAnchorEl] = React.useState<Element | null>(null);
  const isMenuOpen = Boolean(anchorEl);
  const user = useAppSelector((state) => state.user.user);
  const dispatch = useAppDispatch()
  function logOutAction() {
    setAnchorEl(null);
    new AuthenticationApi(apiConfig)
      .logoutLogoutPost()
      .then(() => dispatch(updateUser(null)))
      .catch((e) => console.log(e));
  }
  const renderMenu = (
    <Menu
      anchorEl={anchorEl}
      open={isMenuOpen}
      keepMounted
      onClose={() => setAnchorEl(null)}
    >
      <MenuItem component={RouterLink} to="/profile">
        Moje konto
      </MenuItem>
      <MenuItem component={RouterLink} to="/" onClick={logOutAction}>
        Wyloguj
      </MenuItem>
    </Menu>
  );
  const authorizedRightButton = (
    <div>
      <SelectEnterprise />
      <IconButton
        style={{ marginRight: 2 }}
        onClick={(event) => {
          setAnchorEl(event.currentTarget);
        }}
      >
        <MenuIcon />
      </IconButton>
      {renderMenu}
    </div>
  );

  const unauthorizedRightButton = (
    <Button
      style={{ marginRight: 2 }}
      variant="contained"
      color="secondary"
      component={RouterLink}
      to="/login"
    >
      Zaloguj się
    </Button>
  );
  const RightButton = user
    ? authorizedRightButton
    : unauthorizedRightButton;
  return RightButton;
}
