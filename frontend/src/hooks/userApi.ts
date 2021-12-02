import { QueryClient, useMutation, useQuery } from "react-query";
import { AuthenticationApi, Configuration, LoginInput, RegisterInput, UserApi } from "../generated-api";
export const apiConfig = new Configuration({ basePath: "/api" });

const authApi = new AuthenticationApi(apiConfig)
const queryClient = new QueryClient()
const userApi = new UserApi(apiConfig);
export function useRegisterUser() {
    const login = useLoginUser()
    return useMutation(
        async (data: RegisterInput) => {
            try {
                const register_response = await authApi.registerUserRegisterPost(data)
                login.mutate({ username: data.username, password: data.password })
                return register_response
            } catch (e) {
                throw e
            }
        }
    )
}

export function useLoginUser() {
    const user = useUser();
    return useMutation(
        async (data: LoginInput) => {
            try {
                const login_response = await authApi.loginUserLoginPost(data)
                queryClient.invalidateQueries("user");
                user.refetch();
                return login_response
            } catch (e) {
                throw e
            }
        },
        { onSuccess: () => queryClient.invalidateQueries("user") }
    )
}
export function useLogoutUser() {
    const user = useUser();

    return useMutation(
        async () => {
            try {
                const logoutResponse = await authApi.logoutLogoutPost()
                queryClient.invalidateQueries("user")
                user.refetch()

                return logoutResponse
            }
            catch (e) {
                throw e
            }
        },
        {
            onSuccess: () => { queryClient.invalidateQueries('user') }
        }
    )
}
;
export function useUser() {
    return useQuery({
        queryKey: "user",
        queryFn: async () => {

            const r = await userApi.getUserDataUserMeGet();
            return r;
        },
        retry: false,
    })
}

export function useUserMutationFavEnterprise() {
    const user = useUser()
    return useMutation(
        async (enterprise_id: number) => {
            const r = await userApi.updateEnterpriseUserMePreferredEnterprisePatch(enterprise_id)
            user.refetch()
            return r
        }
    )
}
