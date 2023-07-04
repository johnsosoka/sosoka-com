// ACM & Cloudfront.
resource "aws_acm_certificate" "sosoka_com_acm_cert" {
  // We want a wildcard cert so we can host subdomains later.
  domain_name       = "*.${local.root_domain_name}"
  validation_method = "EMAIL"
  # This is the only region that supports ACM for our purposes.
  provider = aws.east

  // We also want the cert to be valid for the root domain even though we'll be
  // redirecting to the www. domain immediately.
  subject_alternative_names = [local.root_domain_name]
}

// create cloudfront distributions which use the cert from above.

resource "aws_cloudfront_distribution" "www_distribution" {
  default_root_object = "index.html"
  // origin is where CloudFront gets its content from.
  origin {
    // We need to set up a "custom" origin because otherwise CloudFront won't
    // redirect traffic from the root domain to the www domain, that is from
    // johnsosoka.com to www.johnsosoka.com
    custom_origin_config {
      // These are all the defaults.
      http_port              = "80"
      https_port             = "443"
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }

    // Here we're using our S3 bucket's URL!
    domain_name = aws_s3_bucket_website_configuration.www_website_configuration.website_endpoint
    //domain_name = aws_s3_bucket.www.website_endpoint
    // This can be any name to identify this origin.
    origin_id   = local.www_domain_name
  }

  enabled             = true
  // Removing default_root_object so that /index.html doesn't appear in browser bar
  // default_root_object = "index.html"

  // All values are defaults from the AWS console.
  default_cache_behavior {
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    // This needs to match the `origin_id` above.
    target_origin_id       = local.www_domain_name
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  // Here we're ensuring we can hit this distribution using www.johnsosoka.com
  // rather than the domain name CloudFront generates.
  aliases = [local.www_domain_name]

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  // Here's where our certificate is loaded in!
  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.sosoka_com_acm_cert.arn
    ssl_support_method  = "sni-only"
  }
}

resource "aws_cloudfront_distribution" "root_distribution" {
  origin {
    custom_origin_config {
      http_port              = "80"
      https_port             = "443"
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
    domain_name = aws_s3_bucket.root_web.bucket_regional_domain_name
    origin_id   = local.root_domain_name
  }

  enabled             = true

  default_cache_behavior {
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = local.root_domain_name
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  aliases = [local.root_domain_name]

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.sosoka_com_acm_cert.arn
    ssl_support_method  = "sni-only"
  }
}

