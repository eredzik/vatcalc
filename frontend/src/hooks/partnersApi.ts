import { QueryClient, useMutation, useQuery } from "react-query";
import { TradingPartnerApi, TradingPartnerInput } from "../generated-api";
import { apiConfig } from "./userApi";


const tradingPartnersApi = new TradingPartnerApi(apiConfig);
export function useTradingPartnersList(page: number, enterprise_id: number) {
    return useQuery(['trading_partners', enterprise_id, page], async () => {
        const r = await tradingPartnersApi
            .getTradingPartnersTradingPartnerGet(page, enterprise_id)
        return r

    })
}

export function useTradingPartnersAdd() {
    return useMutation(
        async (data: TradingPartnerInput) => {
            const queryClient = new QueryClient()

            const r =
                await tradingPartnersApi
                    .addTradingPartnerTradingPartnerPost(data);
            if (r.status === 204) {
                queryClient.invalidateQueries('trading_partners')
            }
            return r
        }
    )
}