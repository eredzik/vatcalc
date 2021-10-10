import { Button, Menu, MenuItem, Position } from "@blueprintjs/core";
import { Popover2 } from "@blueprintjs/popover2";
import { ItemRenderer, Select } from "@blueprintjs/select";
import { Link } from "@material-ui/core";
import React, { useCallback, useState } from "react";
import { Link as RouterLink, useHistory } from "react-router-dom";
import { EnterpriseResponse } from "../generated-api";
import { useEnterprisesList } from "../hooks/enterpriseApi";
import { useLogoutUser, useUser, useUserMutationFavEnterprise } from "../hooks/userApi";
export const Navbar: React.FC<{}> = () => {
  return (
    <div style={{
      display: "flex",
      justifyContent: "space-between",
      alignItems: "center",
      padding: "1rem 1rem 1rem 1rem",
      backgroundColor: "#6EA4BF"

    }}>
      <Link
        variant="h4"
        color="textPrimary"
        component={RouterLink}
        to="/"
        style={{
          textDecoration: "none",
          fontWeight: "bold"
        }}
      >
        VatCalc
      </Link>
      <RightButton />
    </div >
  );
};


function SelectEnterprise(): JSX.Element {
  const user = useUser();
  const updateFavEnterprise = useUserMutationFavEnterprise();
  const EnterpriseSelect = Select.ofType<EnterpriseResponse>();
  const enterprisesList = useEnterprisesList(1);
  const selectedEnterpriseLabel =
    enterprisesList.data?.data
      .filter(
        (v) => v.enterprise_id === user.data?.data.fav_enterprise_id)[0]?.name ||
    "Wybierz firmę";
  const renderItem: ItemRenderer<EnterpriseResponse> =
    (item, { handleClick, modifiers, query }) => {
      if (!modifiers.matchesPredicate) {
        return null;
      }
      const text = `${item.nip_number}. ${item.name}`;
      return (
        <MenuItem
          active={modifiers.active}
          disabled={modifiers.disabled}
          label={item.address}
          key={item.enterprise_id}
          onClick={handleClick}
          text={text}
        />
      );
    };
  const handleItemSelect = useCallback((enterprise_selected: EnterpriseResponse) => {
    updateFavEnterprise.mutate(enterprise_selected.enterprise_id)
  }, [])
  return (
    <EnterpriseSelect
      filterable={false}
      items={enterprisesList.data?.data || []}
      itemRenderer={renderItem}
      onItemSelect={handleItemSelect}
    >
      <Button text={selectedEnterpriseLabel} rightIcon="caret-down" />

    </EnterpriseSelect >
  );
}

function RightButton() {
  const history = useHistory();
  const user = useUser();
  const logOutAction = useLogoutUser();
  const renderMenuItems = (
    <Menu>
      <MenuItem text="Moje firmy" onClick={() => history.push("/enterprise/add")} />
      <MenuItem text="Faktury" onClick={() => history.push("/invoice")} />
      <MenuItem text="Kontrahenci" onClick={() => history.push("/trading_partner")} />
      <MenuItem text="Ustawienia konta" />
      <MenuItem text="Wyloguj" onClick={() => logOutAction.mutate()} />
    </Menu>
  );
  const RenderMenuButton = () => (
    <div style={{
      marginLeft: "0.5rem"
    }}>
      <Popover2
        modifiers={{ arrow: { enabled: false } }} content={renderMenuItems}
        autoFocus={false}
        position={Position.BOTTOM_LEFT} >
        <Button icon="menu" ></Button>
      </Popover2 >
    </div>
  );
  const authorizedRightButton = (
    <div style={{ display: "flex", justifyContent: 'space-between' }}>
      <SelectEnterprise />
      <RenderMenuButton />
    </div>
  );

  const unauthorizedRightButton = (
    <Button
      color="primary"
      onClick={() => history.push('/login')}
    >
      Zaloguj się
    </Button>
  );
  const RightButton =
    user.isSuccess
      ? authorizedRightButton
      :
      unauthorizedRightButton;
  return RightButton;
}
