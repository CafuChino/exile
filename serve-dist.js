const express = require('express');
const { createProxyMiddleware } = require('http-proxy-middleware');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 8080;

// 代理配置 - 参考 vue.config.js
const proxyConfig = {
  '/api': {
    target: 'https://www.rearyard.com',
    changeOrigin: true,
    secure: false,
  },
  '/control': {
    target: 'https://www.rearyard.com',
    changeOrigin: true,
    secure: false,
  },
  '/message': {
    target: 'https://www.rearyard.com',
    changeOrigin: true,
    secure: false,
  }
};

// 设置代理
Object.keys(proxyConfig).forEach(path => {
  app.use(path, createProxyMiddleware(proxyConfig[path]));
});

// 提供静态文件
app.use(express.static(path.join(__dirname, 'dist')));

// SPA fallback - 所有未匹配的路由返回 index.html
app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, 'dist', 'index.html'));
});

app.listen(PORT, () => {
  console.log(`✨ Server is running at http://localhost:${PORT}`);
  console.log(`📁 Serving: ${path.join(__dirname, 'dist')}`);
  console.log(`🔄 Proxy configured for: ${Object.keys(proxyConfig).join(', ')}`);
});
