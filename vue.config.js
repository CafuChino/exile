module.exports = {
  css: {
    loaderOptions: {
      less: {
        javascriptEnabled: true
      }
    }
  },
  transpileDependencies: [
    /node_modules[\\/]@sentry/,
    /node_modules[\\/]@sentry-internal/
  ],
  devServer: {
    proxy: {
      "/api": {
        target: "https://www.rearyard.com", // 本地模拟数据服务器
        changeOrigin: true,
      },
      "/control":{
        target: "https://www.rearyard.com",
        changeOrigin: true,
      },
      "/message": {
        target: "https://www.rearyard.com", // 本地模拟数据服务器
        changeOrigin: true,
      }
    }
  }
}
