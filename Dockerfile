# Set the maintainer label
LABEL maintainer="you@example.com"

# Update the package list and install necessary packages
RUN apt-get update && apt-get install -y \
    nginx \
    && apt-get clean

# Copy the content to the container
COPY . /var/www/html

# Expose port 80
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]


  
