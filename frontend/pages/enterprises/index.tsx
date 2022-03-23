import { Enterprise } from "@prisma/client";
import { useSession } from "next-auth/react";
import Link from "next/link";
import { useMemo } from "react";
import { useHistory } from "react-router";
import { Cell, useTable } from "react-table";
import { Button, Header, Loader } from "semantic-ui-react";
import { Layout } from "../../components/Layout";
import SimpleTable from "../../components/SimpleTable";
// import { EnterpriseResponse } from "../../src/generated-api";
import { useEnterprisesList } from "../../src/hooks/enterpriseApi";
import { useUser, useUserMutationFavEnterprise } from "../../src/hooks/userApi";
import { trpc } from "../../utils/trpc";

export default function EnterpriseList() {
  // const page = 1;
  // const enterprises = useEnterprisesList(page);

  return (
    <Layout>
      {/* {enterprises.isLoading || enterprises.isError ? ( */}
      {/* <Loader active inline="centered" /> */}
      {/* ) : ( */}
      <Content />
      {/* )} */}
    </Layout>
  );
}
function Content() {
  // const history = useHistory();
  // const user = useUser();
  const session = useSession();
  const enterprises =
    trpc
      .useQuery(["enterprises.availableEnterprises"])
      .data?.map((e) => e.enterprise) || [];
  // const updateFavEnterprise = useUserMutationFavEnterprise();
  // const updateFavEnterpriseMutate = updateFavEnterprise.mutate;
  const fav_enterprise_id = session.data?.user.fav_enterprise_id;
  const columns = useMemo(
    () => [
      {
        Header: "ID firmy",
        accessor: (r: Enterprise) => r.id,
      },
      {
        Header: "Nazwa firmy",
        accessor: (r: Enterprise) => r.name,
      },
      {
        Header: "Numer NIP",
        accessor: (r: Enterprise) => r.nip_number,
      },
      {
        id: "editButton",
        Header: "Opcje",
        Cell: ({ cell }: { cell: Cell<Enterprise> }) => {
          return (
            <Link href={`/enterprises/${cell.row.original.id}`}>
              <Button as="a" icon="cogs" />
            </Link>
          );
        },
      },
      {
        id: "selectButton",
        Header: "Wybierz firmę",
        Cell: ({ cell }: { cell: Cell<Enterprise> }) => {
          if (fav_enterprise_id === cell.row.original.id) {
            return (
              <Button icon="chevron circle right" color="green" disabled />
            );
          }
          return (
            <Button
              icon="chevron right"
              // onClick={() => {
              //   console.log("called");
              //   updateFavEnterpriseMutate(cell.row.original.enterprise_id);
              // }}
            />
          );
        },
      },
    ],
    [fav_enterprise_id]
  );
  const data = useMemo(() => enterprises, [enterprises]);
  console.log(enterprises);
  const react_table = useTable({ columns, data });

  return (
    <>
      <Header
        as="h3"
        icon="factory"
        textAlign="center"
        content="Lista firm"
      ></Header>
      <Link href="/enterprises/add">
        <Button primary content="Dodaj nową firmę" />
      </Link>
      <SimpleTable react_table={react_table} />
    </>
  );
}
EnterpriseList.auth = true;
