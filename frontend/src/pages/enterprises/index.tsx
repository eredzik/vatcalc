import { useMemo } from "react";
import { useHistory } from "react-router";
import { Cell, useTable } from "react-table";
import { Button, Header, Loader } from "semantic-ui-react";
import { Layout } from "../../../components/Layout";
import SimpleTable from "../../../components/SimpleTable";
import { EnterpriseResponse } from "../../generated-api";
import { useEnterprisesList } from "../../hooks/enterpriseApi";
import { useUser, useUserMutationFavEnterprise } from "../../hooks/userApi";

export default function EnterpriseList() {
  const page = 1;
  const enterprises = useEnterprisesList(page);

  return (
    <Layout>
      {enterprises.isLoading || enterprises.isError ? (
        <Loader active inline="centered" />
      ) : (
        <Content enterprises={enterprises.data?.data || []} />
      )}
    </Layout>
  );
}
function Content({ enterprises }: { enterprises: EnterpriseResponse[] }) {
  const history = useHistory();
  const user = useUser();
  const updateFavEnterprise = useUserMutationFavEnterprise();
  const updateFavEnterpriseMutate = updateFavEnterprise.mutate;
  const fav_enterprise_id = user.data?.data.fav_enterprise_id;
  const columns = useMemo(
    () => [
      {
        Header: "ID firmy",
        accessor: (r: EnterpriseResponse) => r.enterprise_id,
      },
      {
        Header: "Nazwa firmy",
        accessor: (r: EnterpriseResponse) => r.name,
      },
      {
        Header: "Numer NIP",
        accessor: (r: EnterpriseResponse) => r.nip_number,
      },
      {
        id: "editButton",
        Header: "Opcje",
        Cell: ({ cell }: { cell: Cell<EnterpriseResponse> }) => {
          return (
            <Button
              icon="cogs"
              onClick={() =>
                history.push(`/enterprise/${cell.row.original.enterprise_id}`)
              }
            />
          );
        },
      },
      {
        id: "selectButton",
        Header: "Wybierz firmę",
        Cell: ({ cell }: { cell: Cell<EnterpriseResponse> }) => {
          if (fav_enterprise_id === cell.row.original.enterprise_id) {
            return (
              <Button icon="chevron circle right" color="green" disabled />
            );
          }
          return (
            <Button
              icon="chevron right"
              onClick={() => {
                console.log("called");
                updateFavEnterpriseMutate(cell.row.original.enterprise_id);
              }}
            />
          );
        },
      },
    ],
    [fav_enterprise_id, history, updateFavEnterpriseMutate]
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
      <Button
        primary
        content="Dodaj nową firmę"
        onClick={() => history.push("/enterprise/add")}
      />
      <SimpleTable react_table={react_table} />
    </>
  );
}
