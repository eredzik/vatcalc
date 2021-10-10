import { TableInstance } from "react-table";
import { Table } from "semantic-ui-react";
interface ISimpleTable<D extends object> {
    react_table: TableInstance<D>
}
export default function SimpleTable<D extends object = {}>
    ({ react_table }: ISimpleTable<D>) {
    return (
        <Table unstackable>
            <Table.Header>
                <Table.Row>
                    {react_table.headerGroups.map(
                        header_group => header_group.headers.map(
                            column =>
                                <Table.HeaderCell>
                                    {column.render("Header")}
                                </Table.HeaderCell>))}
                </Table.Row>
            </Table.Header>
            <Table.Body>
                {react_table.rows.map(row => {
                    react_table.prepareRow(row);
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
        </Table>)
}