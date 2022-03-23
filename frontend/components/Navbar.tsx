import { Menu, MenuItem, Position } from "@blueprintjs/core";
import { Popover2 } from "@blueprintjs/popover2";
import { ItemRenderer, Select } from "@blueprintjs/select";
import Link from "next/link";
import React from "react";

import { EnterpriseResponse } from "../src/generated-api";
// import { useEnterprisesList } from "../src/hooks/enterpriseApi";
import { useSession, signIn, signOut } from "next-auth/react";
import { Dropdown, Button } from "semantic-ui-react";
import { trpc } from "../utils/trpc";

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
const reloadSession = () => {
  const event = new Event("visibilitychange");
  document.dispatchEvent(event);
};
function SelectEnterprise(): JSX.Element {
  const session = useSession();
  const trpcContext = trpc.useContext();
  const updateFavEnterprise = trpc.useMutation("enterprises.setFavEnterprise");
  const allUserEnterprises = trpc.useQuery([
    "enterprises.availableEnterprises",
  ]).data;
  const userEnterprises =
    allUserEnterprises?.map((e) => ({
      text: e.enterprise.name,
      value: e.enterprise.id,
    })) || [];
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
  console.log(
    allUserEnterprises?.filter(
      (e) => e.enterprise_id === session.data?.user.fav_enterprise_id
    )[0].enterprise.name
  );
  return (
    <Dropdown
      className="icon"
      // search
      selection
      labeled
      button
      icon="factory"
      // filterable={false}
      // items={userEnterprises || []}
      options={userEnterprises}
      text={
        allUserEnterprises?.filter(
          (e) => e.enterprise_id === session.data?.user.fav_enterprise_id
        )[0]?.enterprise.name || "Wybierz firmę"
      }
      // itemRenderer={renderItem}

      onChange={async (e, data) => {
        console.log(data, e);
        const res = await updateFavEnterprise.mutateAsync({
          enterprise_id: data.value as number,
        });
        if (res) {
          reloadSession();
        }
      }}
    />
  );
}

function RightButton({ session }: { session: any }) {
  // const user = useUser();
  // const logOutAction = useLogoutUser();
  const renderMenuItems = (
    <Menu>
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
      // options={[
      //   {
      //     key: "enterprise",
      //     text: <Dropdown.Item href="/enterprises" children="Moje firmy" />,
      //   },
      //   { key: "invoice", text: <Link href="/invoices" children="Faktury" /> },
      // ]}
    >
      <Dropdown.Menu>
        <Dropdown.Item text="Firmy" href="/enterprises" />
        <Dropdown.Item text="Faktury" href="/invoices" />
        <Dropdown.Item text="Kontrahenci" href="/trading_partners" />
        <Dropdown.Item text="Wyloguj" onClick={() => signOut()} />
      </Dropdown.Menu>
    </Dropdown>
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
