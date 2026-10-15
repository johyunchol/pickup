import type { NextConfig } from "next";

// 브라우저는 같은 출처의 /api/* 로 부르고, Next 가 api 서버로 넘긴다 — CORS 설정이 필요 없다.
const API_URL = process.env.API_URL ?? "http://localhost:4000";

const nextConfig: NextConfig = {
  devIndicators: false,
  async rewrites() {
    return [{ source: "/api/:path*", destination: `${API_URL}/:path*` }];
  },
};

export default nextConfig;
