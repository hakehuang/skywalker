<html>
<body>
<marquee direction=left scrollamount=6>When I move, generating OK</marquee>
<?php
system("/rootfs/wb/gen_html.sh \"IMX50RDP IMX53LOCO IMX53SMD\"");
echo "<p>result generated!</p>";
?>

</body>
</html>
