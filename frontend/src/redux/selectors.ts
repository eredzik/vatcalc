import { TypedUseSelectorHook, useDispatch, useSelector } from "react-redux";
import store, { RootState } from "./store";

export const useAppSelector: TypedUseSelectorHook<RootState> = useSelector;

export type AppDispatch = typeof store.dispatch
export const useAppDispatch = () => useDispatch<AppDispatch>() // Export a hook that can be reused to resolve types
