// Dark mode helper for Symrise Dashboard

$(document).ready(function() {
  // Function to check and apply dark mode fixes
  function applyDarkModeFixes() {
    // Check if dark mode is enabled
    if ($('body').hasClass('dark-mode')) {
      // Force dark styling on navbar
      $('.main-header').removeClass('navbar-light navbar-white').addClass('navbar-dark');
      $('.main-header .navbar').removeClass('navbar-light navbar-white').addClass('navbar-dark');
      
      // Force dark styling on sidebar
      $('.main-sidebar').removeClass('sidebar-light-primary').addClass('sidebar-dark-primary');
      
      // Add custom dark mode indicator
      $('body').addClass('symrise-dark-mode');
    } else {
      // Remove custom dark mode indicator
      $('body').removeClass('symrise-dark-mode');
    }
  }
  
  // Apply fixes on page load
  applyDarkModeFixes();
  
  // Watch for dark mode toggle
  var observer = new MutationObserver(function(mutations) {
    mutations.forEach(function(mutation) {
      if (mutation.attributeName === "class") {
        applyDarkModeFixes();
      }
    });
  });
  
  // Start observing body for class changes
  observer.observe(document.body, {
    attributes: true,
    attributeFilter: ['class']
  });
  
  // Also listen for controlbar toggle (dark mode switch)
  $(document).on('click', '[data-widget="control-sidebar"]', function() {
    setTimeout(applyDarkModeFixes, 100);
  });
});