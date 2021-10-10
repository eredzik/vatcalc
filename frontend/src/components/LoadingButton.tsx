import { Button, ButtonProps, CircularProgress } from "@material-ui/core"


// export interface IButtonWithLoading extends ButtonProps {
//     isLoading: boolean
// }
// export const ButtonWithLoading = ({ isLoading, children, ...props }: IButtonWithLoading) => {
//     return (<Button {...props}>
//         {(!isLoading) && children}
//         {isLoading && <CircularProgress color="secondary" size={24} />}
//     </Button>)
// }