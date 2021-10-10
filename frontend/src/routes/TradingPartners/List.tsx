import { Button } from "@blueprintjs/core";
import React from "react";
import { useHistory } from "react-router";
import { useTable } from 'react-table';
import { Container, Table } from 'semantic-ui-react';
import { TradingPartnerResponse } from "../../generated-api/api";
import { useEnterprisesList } from "../../hooks/enterpriseApi";
import { useTradingPartnersList } from "../../hooks/partnersApi";
import { useUser } from "../../hooks/userApi";
export default function TradingPartnersList() {
    const user = useUser();
    const history = useHistory();
    const enterprises = useEnterprisesList(1);
    const fav_enterprise_id = user.data?.data.fav_enterprise_id || enterprises.data?.data[0] || -1;

    if (!fav_enterprise_id) {
        history.push('/')
    }
    const tradingPartnersList = useTradingPartnersList(
        1,
        fav_enterprise_id as number) // always has to be present - eliminated by redirect above
    const columns = React.useMemo(
        () => [
            { Header: "ID", accessor: (r: TradingPartnerResponse) => r.id },
            { Header: "Nazwa", accessor: (r: TradingPartnerResponse) => r.name },
            { Header: "Adres", accessor: (r: TradingPartnerResponse) => r.address },
            { Header: "Numer NIP", accessor: (r: TradingPartnerResponse) => r.nip_number },
        ], []
    )
    const data = React.useMemo(() =>
        tradingPartnersList.data &&
            tradingPartnersList.data.data.length > 0 ?
            tradingPartnersList.data?.data :
            [{
                id: 0,
                address: "placeholder",
                enterprise_id: 0,
                name: "Placeholder_name",
                nip_number: "Nip_placeholder"
            }] as TradingPartnerResponse[],
        [tradingPartnersList])
    const {
        getTableProps,
        getTableBodyProps,
        headerGroups,
        rows,
        prepareRow,
    } = useTable({
        columns,
        data,
    })
    return (
        <Container style={{ marginTop: "2em" }}>
            <Table celled selectable>
                <Table.Header>
                    <Table.Row>
                        {headerGroups.map(
                            header_group => header_group.headers.map(
                                column =>
                                    <Table.HeaderCell>
                                        {column.render("Header")}
                                    </Table.HeaderCell>))}
                    </Table.Row>
                </Table.Header>
                <Table.Body>
                    {rows.map(row => {
                        prepareRow(row);
                        return <Table.Row>
                            {row.cells.map(
                                cell =>
                                    <Table.Cell>
                                        {cell.render("Cell")}
                                    </Table.Cell>
                            )}
                        </Table.Row>
                    })}
                </Table.Body>
            </Table>
            <Button
                rightIcon="arrow-right"
                intent="success"
                onClick={() => history.push("/trading_partner/add")}>
                Dodaj kontrahenta
            </Button>
        </Container>
    )
}