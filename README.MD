# Nginx Reverse Proxy Special Character Handler

## Project Overview

This project demonstrates a proof of concept for handling potentially dangerous special characters in URLs using an Nginx reverse proxy. It specifically focuses on redirecting URLs containing unescaped percent signs (`%`) to a custom error page, preventing potential security vulnerabilities.

## Security Risk: Unhandled Special Characters

Unhandled special characters in URLs can expose sensitive information about your infrastructure. For example:

- A URL like `https://www.example.com/%` can trigger a 400 Bad Request error
- Without proper handling, some servers may expose internal details in error responses
- Real-world example: `https://www.palantir.com/%` has been observed to return a `ListBucketResult` XML response, potentially exposing S3 bucket information

This type of information disclosure can be leveraged by attackers to gather intelligence about your backend infrastructure, potentially leading to more targeted attacks.

## How It Works

This project implements a reverse proxy that:

1. Intercepts all incoming requests
2. Detects URLs containing unescaped special characters like `%`
3. Maps HTTP 400 Bad Request errors to a custom error page
4. Provides a clean, user-friendly error message instead of exposing system details

### Nginx Configuration

The key components of the Nginx configuration:

```nginx
# Handle 400 Bad Request errors (malformed URLs like those with unescaped % characters)
error_page 400 = /error.html;

# Specific location for error.html - serve directly
location = /error.html {
    # Serve error.html directly
}

# Default location - proxy to backend
location / {
    proxy_pass https://doit.com/;
}
```

## Running the Project

### Prerequisites

- Docker installed on your system

### Building and Running

1. Build the Docker image:
   ```bash
   docker build -t nginx-reverse-proxy -f Dockerfile .
   ```

2. Run the container:
   ```bash
   docker run -it --rm -p 80:80 nginx-reverse-proxy
   ```

## Testing the Special Character Handling

### Test Case 1: Normal Request
```bash
curl http://localhost/
```
Expected result: The request will be proxied to the backend server.

### Test Case 2: URL with Unescaped Percent Sign
```bash
curl http://localhost/%
```
Expected result: You will see the custom error page instead of a server error or bucket listing.

### Test Case 3: Browser Test
1. Open your web browser
2. Navigate to `http://localhost/%`
3. You should see the custom error page with "Page Not Found" message

## Project Structure

- `error.html` - Custom error page shown for invalid URLs
- `nginx.conf` - Nginx server configuration with special character handling
- `Dockerfile` - Instructions for building the Docker container

## Security Benefits

This configuration provides several security benefits:

1. **Information Hiding**: Prevents exposure of backend infrastructure details
2. **Consistent User Experience**: Users see a friendly error page instead of technical errors
3. **Attack Surface Reduction**: Blocks potential paths for URL-based attacks
4. **Logging Control**: Allows proper logging of potentially malicious requests

## Best Practices for Production Use

For production environments, consider these additional enhancements:

1. **Timeout Settings**:
   ```nginx
   proxy_connect_timeout 60s;
   proxy_read_timeout 60s;
   proxy_send_timeout 60s;
   ```

2. **Buffer Settings**:
   ```nginx
   proxy_buffer_size 128k;
   proxy_buffers 4 256k;
   proxy_busy_buffers_size 256k;
   ```

3. **Additional Security Headers**:
   ```nginx
   add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
   add_header Content-Security-Policy "default-src 'self';" always;
   add_header Referrer-Policy "no-referrer-when-downgrade" always;
   ```

## Conclusion

This project demonstrates an effective approach to handling special characters in URLs using Nginx as a reverse proxy. By properly configuring error handling and implementing custom error pages, you can prevent information disclosure vulnerabilities while providing a better user experience.