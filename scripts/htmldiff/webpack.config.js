const webpack = require('webpack');
const path = require('path');
const UnminifiedWebpackPlugin = require('unminified-webpack-plugin');
const {CleanWebpackPlugin} = require('clean-webpack-plugin');

module.exports = {
    entry: {
        htmldiff: ['babel-polyfill', './src/Diff.js'],
    },

    output: {
        filename: 'htmldiff.min.js',
        path: path.resolve(__dirname, 'dist'),
        publicPath: '/dist/',
        library: 'HtmlDiff',
        libraryTarget: 'commonjs2'
    },

    module: {
        rules: [
            {
                test: /\.m?js$/,
                exclude: /(node_modules|bower_components)/,
                use: {
                    loader: 'babel-loader',
                }
            }
        ]
    },

    plugins: [
        new CleanWebpackPlugin(),
        new UnminifiedWebpackPlugin()
    ],

    optimization: {
        minimize: true
    }
};