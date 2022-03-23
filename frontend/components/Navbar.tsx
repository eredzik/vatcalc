import { Menu, MenuItem, Position } from "@blueprintjs/core";
import { Popover2 } from "@blueprintjs/popover2";
import { ItemRenderer, Select } from "@blueprintjs/select";
import Link from "next/link";
import React from "react";

import { EnterpriseResponse } from "../src/generated-api";
// import { useEnterprisesList } from "../src/hooks/enterpriseApi";
import { useSession, signIn, signOut } from "next-auth/react";
import { Dropdown, Button } from "semantic-ui-react";

// import {
//   useLogoutUser,
//   useUser,
//   useUserMutationFavEnterprise,
// } from "../src/hooks/userApi";
export const Navbar: React.FC<{}> = () => {
  const { data: session } = useSession();

  return (
    <div
      style={{
        display: "flex",
        justifyContent: "space-between",
        alignItems: "center",
        padding: "1rem 1rem 1rem 1rem",
        backgroundColor: "#6EA4BF",
      }}
    >
      <Link href="/">
        <h4
          style={{
            textDecoration: "none",
            fontWeight: "bold",
          }}
        >
          VatCalc
        </h4>
      </Link>
      <RightButton session={session} />
    </div>
  );
};

function SelectEnterprise(): JSX.Element {
  // const user = useUser();
  // const updateFavEnterprise = useUserMutationFavEnterprise();

  // const enterprisesList = useEnterprisesList(1);
  // const selectedEnterpriseLabel =
  //   enterprisesList.data?.data.filter(
  //     (v) => v.enterprise_id === user.data?.data.fav_enterprise_id
  //   )[0]?.name || "Wybierz firmę";
  const selectedEnterpriseLabel = "Wybierz firmę";
  const renderItem: ItemRenderer<EnterpriseResponse> = (
    item,
    { handleClick, modifiers, query }
  ) => {
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

  return (
    <Dropdown
      className="icon"
      search
      selection
      labeled
      button
      icon="factory"
      // filterable={false}
      // items={enterprisesList.data?.data || []}
      options={[]}
      text="Wybierz firmę"
      // itemRenderer={renderItem}
      // onItemSelect={() => {}}
      // onItemSelect={(enterprise_selected) =>
      //   updateFavEnterprise.mutate(enterprise_selected.enterprise_id)
      // }
    />
  );
}

function RightButton({ session }: { session: any }) {
  // const user = useUser();
  // const logOutAction = useLogoutUser();
  const renderMenuItems = (
    <Menu>
      <Link href="/enterprise">
        <MenuItem
          text="Moje firmy"
          // onClick={() => history.push("/enterprise")}
        />
      </Link>
      <Link href="/invoice">
        <MenuItem
          text="Faktury"
          // onClick={() => history.push("/invoice")}
        />
      </Link>
      <Link href="/trading_partner">
        <MenuItem
          text="Kontrahenci"
          // onClick={() => history.push("/trading_partner")}
        />
      </Link>
      <MenuItem text="Ustawienia konta" />
      <MenuItem text="Wyloguj" onClick={() => signOut()} />
    </Menu>
  );
  const RenderMenuButton = () => (
    <Dropdown
      icon="bars"
      className="icon"
      button
      text=" "
      floating
      direction="left"
      options={[
        {
          key: "enterprise",
          text: <Link href="/enterprises" children="Moje firmy" />,
        },
      ]}
    />
  );
  const authorizedRightButton = (
    <div style={{ display: "flex", justifyContent: "space-between" }}>
      <SelectEnterprise />
      <RenderMenuButton />
    </div>
  );

  const unauthorizedRightButton = (
    // <Link href="/login">
    <Button onClick={() => signIn()}>Zaloguj się</Button>
    // </Link>
  );
  const RightButton = session ? authorizedRightButton : unauthorizedRightButton;
  return RightButton;
}
