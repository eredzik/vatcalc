import { useMutation, useQuery, UseQueryResult } from "react-query";
import {
    EnterpriseApi, EnterpriseCreateInput,
    REGONAPIApi, RegonApiNotFoundFailure, RegonApiSuccess
} from "../generated-api";
import { apiConfig } from "./userApi";
function isSuccess(object: RegonApiSuccess | RegonApiNotFoundFailure):
    object is RegonApiSuccess {
    return 'nip' in object;
}
export function useREGONQueryByNIP(nipNumber: string):
    UseQueryResult<RegonApiSuccess, RegonApiNotFoundFailure> {
    return useQuery(
        ["REGONDB_nip", nipNumber], async () => {
            try {
                const response = await new REGONAPIApi(apiConfig)
                    .getInfoByNipRegonApiNipNumberNipNumberGet(
                        nipNumber
                    )

                if (isSuccess(response.data)) {
                    return response.data
                }
                else {
                    throw response.data
                }
            }


            catch (e) {
                throw e
            }
        }
        , {
            retry: false,
            enabled: false
        }
    )
}
const enterpriseApi = new EnterpriseApi(apiConfig);

export function useEnterpriseMutation() {
    const enterprises = useEnterprisesList(1);
    return useMutation(
        async (data: EnterpriseCreateInput) => {
            const r = await enterpriseApi
                .createEnterpriseEnterprisePost(data);
            enterprises.refetch();
            return r
        }

    )
}

export function useEnterprisesList(page: number) {

    return useQuery(['enterprises', page], async () => {
        return await enterpriseApi.getUserEnterprisesEnterpriseGet(page);
    })


}