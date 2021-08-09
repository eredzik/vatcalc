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
            use: [
                {
                    loader: 'file-loader',
                    options: {
                        name: '[name].[ext]',
                        outputPath: 'fonts/'
                    }
                }
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
        proxy: {
            '/api': {
                target: 'http://backend:5000',
                pathRewrite: { '^/api': '' },
            },
        },
        contentBase: path.join(__dirname, "src"),
        stats: 'errors-only',
        historyApiFallback: {
            rewrites: [
                { from: /\.*.bundle.js/, to: '/main.bundle.js' },
                { from: /./, to: '/' },

            ],
        },
        before: function (app) {
            app.get('/api', async function (req, res) {
                try {
                    const queryURL = req.query.q;
                    const resp = await fetch(queryURL);
                    const body = await resp.text();
                    res.send(body);
                } catch (e) {
                    res.status(500);
                    res.send(e);
                }
            });
        }
        ,
    },
};