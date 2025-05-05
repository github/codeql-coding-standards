#!/usr/bin/env python3
"""
Add risk assessment tags to rule package JSON files.

This script:
1. Iterates through each JSON file in rule_packages directory
2. Looks for CERT-C or CERT-CPP sections
3. For each rule, finds the corresponding markdown file
4. Extracts risk assessment data from the markdown file
5. Adds risk assessment data as tags to each query in the JSON file
"""

import os
import json
import re
import glob
from bs4 import BeautifulSoup
import logging

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

def find_rule_packages():
    """Find all JSON rule package files in the rule_packages directory."""
    repo_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    rule_packages_dir = os.path.join(repo_root, "rule_packages")
    return glob.glob(os.path.join(rule_packages_dir, "**", "*.json"), recursive=True)

def extract_risk_assessment_from_md(md_file_path):
    """Extract risk assessment data from the markdown file."""
    risk_data = {}
    
    try:
        with open(md_file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Find the Risk Assessment section
        risk_section_match = re.search(r'## Risk Assessment(.*?)##', content, re.DOTALL)
        if not risk_section_match:
            # Try to find it as the last section
            risk_section_match = re.search(r'## Risk Assessment(.*?)$', content, re.DOTALL)
            if not risk_section_match:
                logger.warning(f"No Risk Assessment section found in {md_file_path}")
                return risk_data
        
        risk_section = risk_section_match.group(1)
        
        # Look for the table with risk assessment data
        table_match = re.search(r'<table>(.*?)</table>', risk_section, re.DOTALL)
        if not table_match:
            logger.warning(f"No risk assessment table found in {md_file_path}")
            return risk_data
        
        table_html = table_match.group(0)
        soup = BeautifulSoup(table_html, 'html.parser')
        
        # Find all rows in the table
        rows = soup.find_all('tr')
        if len(rows) < 2:  # Need at least header and data row
            logger.warning(f"Incomplete risk assessment table in {md_file_path}")
            return risk_data
        
        # Extract headers and values
        headers = [th.get_text().strip() for th in rows[0].find_all('th')]
        values = [td.get_text().strip() for td in rows[1].find_all('td')]
        
        # Create a dictionary of headers and values
        if len(headers) == len(values):
            for i, header in enumerate(headers):
                risk_data[header] = values[i]
        else:
            logger.warning(f"Header and value count mismatch in {md_file_path}")
        
    except Exception as e:
        logger.error(f"Error extracting risk assessment from {md_file_path}: {e}")
    
    return risk_data

def find_md_file(rule_id, short_name, language):
    """Find the markdown file for the given rule ID and short name."""
    repo_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    md_path = os.path.join(repo_root, language, "cert", "src", "rules", rule_id, f"{short_name}.md")
    
    if os.path.exists(md_path):
        return md_path
    else:
        # Try without short name (sometimes the file is named after the rule ID)
        md_path = os.path.join(repo_root, language, "cert", "src", "rules", rule_id, f"{rule_id}.md")
        if os.path.exists(md_path):
            return md_path
        else:
            logger.warning(f"Could not find markdown file for {language} rule {rule_id} ({short_name})")
            return None

def process_rule_package(rule_package_file):
    """Process a single rule package JSON file."""
    try:
        with open(rule_package_file, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        modified = False
        
        # Look for CERT-C and CERT-CPP sections
        for cert_key in ["CERT-C", "CERT-C++"]:
            if cert_key in data:
                language = "c" if cert_key == "CERT-C" else "cpp"
                
                # Process each rule in the CERT section
                for rule_id, rule_data in data[cert_key].items():
                    if "queries" in rule_data:
                        for query in rule_data["queries"]:
                            if "short_name" in query:
                                md_file = find_md_file(rule_id, query["short_name"], language)
                                
                                if md_file:
                                    risk_data = extract_risk_assessment_from_md(md_file)
                                    
                                    if risk_data:
                                        # Add risk assessment data as tags
                                        if "tags" not in query:
                                            query["tags"] = []
                                        
                                        # Add each risk assessment property as a tag
                                        for key, value in risk_data.items():
                                            key_sanitized = key.lower().replace(" ", "-")
                                            if key_sanitized == "rule" or key_sanitized == "recommendation":
                                                # skip rule/recommendation as they just repeat the rule ID
                                                continue
                                            tag = f"external/cert/{key_sanitized}/{value.lower()}"
                                            if tag not in query["tags"]:
                                                query["tags"].append(tag)
                                                modified = True
                                                logger.info(f"Added tag {tag} to {rule_id} ({query['short_name']})")
        
        # Save the modified data back to the file if any changes were made
        if modified:
            with open(rule_package_file, 'w', encoding='utf-8') as f:
                json.dump(data, f, indent=2)
            logger.info(f"Updated {rule_package_file}")
        else:
            logger.info(f"No changes made to {rule_package_file}")
            
    except Exception as e:
        logger.error(f"Error processing {rule_package_file}: {e}")

def main():
    """Main function to process all rule packages."""
    logger.info("Starting risk assessment tag addition process")
    
    rule_packages = find_rule_packages()
    logger.info(f"Found {len(rule_packages)} rule package files")
    
    for rule_package in rule_packages:
        logger.info(f"Processing {rule_package}")
        process_rule_package(rule_package)
    
    logger.info("Completed risk assessment tag addition process")

if __name__ == "__main__":
    main()