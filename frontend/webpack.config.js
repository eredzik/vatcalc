const HtmlWebpackPlugin = require("html-webpack-plugin");
const path = require("path");
const { DefinePlugin } = require("webpack");

module.exports = {
    entry: {
        main: './src/index.js'
    },
    output: {
        filename: "[name].bundle.js",
        path: path.resolve(__dirname, "./dist"),
        clean: true,
    },
    module: {
        rules: [{
            test: /\.html$/,
            exclude: /node_modules/,
            loader: 'file-loader'
        },
        {
            test: /\.elm$/,
            exclude: [/elm-stuff/, /node_modules/],
            loader: "elm-webpack-loader",
        },
        {
            test: /\.css$/,
            use: [
                'style-loader',
                'css-loader'
            ]
        }
        ]
    },
    plugins: [
        new DefinePlugin({
            'process.env.API_SERVER': JSON.stringify(process.env.API_SERVER),
        }),
        new HtmlWebpackPlugin({
            title: "VatCalc",
            favicon: "./src/static/favicon.ico"
        })
    ]
    ,
    devServer: {
        contentBase: path.join(__dirname, "src"),
        stats: 'errors-only',
        historyApiFallback: true
    },
};