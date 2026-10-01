# Fixture: intentionally bad. Do not copy into real projects.
FROM node:latest
WORKDIR /app
COPY . .
ENV STRIPE_SECRET=sk_test_fixture_only
RUN npm install
EXPOSE 3000
CMD ["node", "index.js"]
