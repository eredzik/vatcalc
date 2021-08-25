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
        },
        {
            test: /\.scss$/,
            use: ['style-loader', 'css-loader', 'sass-loader']
        },
        {
            test: /\.svg$/,
            use: [
                {
                    loader: 'svg-url-loader',
                    options: {
                        limit: 10000,
                    },
                },
            ],
        },
        {
            test: /\.(woff(2)?|ttf|eot|svg)(\?v=\d+\.\d+\.\d+)?$/,
            type: 'asset/resource'
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
    output: {
        publicPath: "/"
    },
    devServer: {
        proxy: {
            '/api': {
                target: 'http://backend:5000',
                pathRewrite: { '^/api': '' },
            },
        },
        static: path.join(__dirname, "src"),
        historyApiFallback: true
    },
};