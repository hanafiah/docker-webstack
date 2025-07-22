<?php
// Security: Disable in production
if (getenv('APP_ENV') === 'production') {
    http_response_code(404);
    exit('Not found');
}

// Display PHP information
phpinfo();
