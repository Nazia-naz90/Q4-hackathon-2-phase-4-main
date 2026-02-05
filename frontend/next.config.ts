import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  /* config options here */
  output: 'standalone',
  experimental: {
    // Disable the experimental react compiler that might be causing issues
  },
  // Disable the react compiler if it's causing issues
  reactCompiler: false,
};

export default nextConfig;
