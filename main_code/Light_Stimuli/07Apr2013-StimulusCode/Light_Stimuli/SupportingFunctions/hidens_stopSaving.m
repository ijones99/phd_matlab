%client side:
function hidens_stopSaving(plugNum, hostAddr)
    sockcon = pnet('tcpsocket', 11112); % only create this socket once
    con=pnet('tcpconnect', hostAddr,11112);
    pnet(con,'setwritetimeout', 1);
    pnet(con,'printf', 'select %d\n', plugNum);
    pnet(con,'printf', 'save_stop\n');
    pnet(con, 'close'); 
end
